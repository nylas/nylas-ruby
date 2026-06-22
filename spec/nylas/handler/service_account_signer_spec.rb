# frozen_string_literal: true

require "openssl"

describe Nylas::ServiceAccountSigner do
  let(:private_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:private_key_pem) { private_key.to_pem }

  describe ".canonical_json" do
    it "sorts keys recursively and omits extra whitespace" do
      payload = {
        z: [{ b: 1, a: 2 }],
        y: { b: true, a: "value" }
      }

      expect(described_class.canonical_json(payload))
        .to eq('{"y":{"a":"value","b":true},"z":[{"a":2,"b":1}]}')
    end
  end

  describe ".generate_nonce" do
    it "generates a secure alphanumeric nonce with the requested length" do
      nonce = described_class.generate_nonce(24)

      expect(nonce.length).to eq(24)
      expect(nonce).to match(/\A[A-Za-z0-9]+\z/)
    end
  end

  describe ".load_rsa_private_key" do
    it "rejects public keys" do
      expect { described_class.load_rsa_private_key(private_key.public_key.to_pem) }
        .to raise_error(ArgumentError, /private key/)
    end
  end

  describe "#build_headers" do
    it "builds deterministic signed headers and canonical body for fixed inputs" do
      signer = described_class.new(private_key_pem: private_key_pem, private_key_id: "kid-123")
      body = { name: "My domain", domain_address: "mail.example.com" }

      headers, serialized_body = signer.build_headers(
        method: :post,
        path: "/v3/admin/domains",
        body: body,
        timestamp: 1_700_000_000,
        nonce: "nonce123456789012345"
      )

      expected_body = '{"domain_address":"mail.example.com","name":"My domain"}'
      expected_envelope = described_class.canonical_json(
        method: "post",
        nonce: "nonce123456789012345",
        path: "/v3/admin/domains",
        payload: expected_body,
        timestamp: 1_700_000_000
      )
      expected_signature = Base64.strict_encode64(
        private_key.sign(OpenSSL::Digest.new("SHA256"), expected_envelope)
      )

      expect(serialized_body).to eq(expected_body)
      expect(headers).to eq(
        "X-Nylas-Kid" => "kid-123",
        "X-Nylas-Nonce" => "nonce123456789012345",
        "X-Nylas-Timestamp" => "1700000000",
        "X-Nylas-Signature" => expected_signature
      )
      expect(private_key.public_key.verify(
               OpenSSL::Digest.new("SHA256"),
               Base64.decode64(headers["X-Nylas-Signature"]),
               expected_envelope
             )).to be(true)
    end

    it "omits serialized body for GET requests" do
      signer = described_class.new(private_key_pem: private_key_pem, private_key_id: "kid-123")

      headers, serialized_body = signer.build_headers(
        method: "GET",
        path: "/v3/admin/domains",
        timestamp: 1,
        nonce: "n" * 20
      )

      expect(serialized_body).to be_nil
      expect(headers["X-Nylas-Signature"]).not_to be_empty
    end
  end
end
