# frozen_string_literal: true

describe Nylas::Domains do
  let(:domains) { described_class.new(client) }
  let(:signed_headers) do
    {
      "X-Nylas-Kid" => "service-account-123",
      "X-Nylas-Timestamp" => "1742932766",
      "X-Nylas-Nonce" => "nonce-123",
      "X-Nylas-Signature" => "signature-123"
    }
  end
  let(:response) do
    [{
      id: "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab",
      name: "Marketing domain",
      domain_address: "mail.example.com",
      organization_id: "org-123",
      branded: false,
      region: "us",
      verified_ownership: false,
      verified_mx: false,
      verified_spf: false,
      verified_feedback: false,
      verified_dkim: false,
      verified_dmarc: false,
      verified_arc: false,
      created_at: 1234567890,
      updated_at: 1234567890
    }, "mock_request_id"]
  end

  describe "#list" do
    let(:list_response) do
      [[response[0]], response[1], "mock_next_cursor"]
    end

    it "calls the get_list method with the correct parameters" do
      path = "#{api_uri}/v3/admin/domains"
      allow(domains).to receive(:get_list)
        .with(path: path, query_params: nil, headers: signed_headers)
        .and_return(list_response)

      domains_response = domains.list(headers: signed_headers)

      expect(domains_response).to eq(list_response)
    end

    it "calls the get_list method with the correct parameters and query params" do
      query_params = { domain: "mail.example.com", region: "us" }
      path = "#{api_uri}/v3/admin/domains"
      allow(domains).to receive(:get_list)
        .with(path: path, query_params: query_params, headers: signed_headers)
        .and_return(list_response)

      domains_response = domains.list(query_params: query_params, headers: signed_headers)

      expect(domains_response).to eq(list_response)
    end
  end

  describe "#find" do
    it "calls the get method with the correct parameters" do
      domain_id = "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab"
      path = "#{api_uri}/v3/admin/domains/#{domain_id}"
      allow(domains).to receive(:get)
        .with(path: path, headers: signed_headers)
        .and_return(response)

      domain_response = domains.find(domain_id: domain_id, headers: signed_headers)

      expect(domain_response).to eq(response)
    end

    it "accepts a domain address as the identifier" do
      domain_id = "mail.example.com"
      path = "#{api_uri}/v3/admin/domains/#{domain_id}"
      allow(domains).to receive(:get)
        .with(path: path, headers: signed_headers)
        .and_return(response)

      domain_response = domains.find(domain_id: domain_id, headers: signed_headers)

      expect(domain_response).to eq(response)
    end
  end

  describe "#create" do
    it "calls the post method with the correct parameters" do
      request_body = {
        name: "Marketing domain",
        domain_address: "mail.example.com"
      }
      path = "#{api_uri}/v3/admin/domains"
      allow(domains).to receive(:post)
        .with(path: path, request_body: request_body, headers: signed_headers)
        .and_return(response)

      domain_response = domains.create(request_body: request_body, headers: signed_headers)

      expect(domain_response).to eq(response)
    end
  end

  describe "#update" do
    it "calls the put method with the correct parameters" do
      domain_id = "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab"
      request_body = { name: "Renamed domain" }
      path = "#{api_uri}/v3/admin/domains/#{domain_id}"
      allow(domains).to receive(:put)
        .with(path: path, request_body: request_body, headers: signed_headers)
        .and_return([{ name: "Renamed domain", updated_at: 1234567890 }, "mock_request_id"])

      domain_response = domains.update(domain_id: domain_id, request_body: request_body,
                                       headers: signed_headers)

      expect(domain_response).to eq([{ name: "Renamed domain", updated_at: 1234567890 }, "mock_request_id"])
    end
  end

  describe "#destroy" do
    it "calls the delete method with the correct parameters" do
      domain_id = "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab"
      path = "#{api_uri}/v3/admin/domains/#{domain_id}"
      allow(domains).to receive(:delete)
        .with(path: path, headers: signed_headers)
        .and_return([true, "mock_request_id"])

      domain_response = domains.destroy(domain_id: domain_id, headers: signed_headers)

      expect(domain_response).to eq([true, "mock_request_id"])
    end
  end

  describe "#info" do
    it "calls the post method with the correct parameters" do
      domain_id = "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab"
      request_body = { type: "ownership" }
      path = "#{api_uri}/v3/admin/domains/#{domain_id}/info"
      result = [{
        domain_id: domain_id,
        attempt: { type: "ownership",
                   options: { host: "example.com", type: "TXT", value: "nylas-verify=abc" } },
        status: "pending",
        message: "Please configure the TXT record."
      }, "mock_request_id"]
      allow(domains).to receive(:post)
        .with(path: path, request_body: request_body, headers: signed_headers)
        .and_return(result)

      domain_response = domains.info(domain_id: domain_id, request_body: request_body,
                                     headers: signed_headers)

      expect(domain_response).to eq(result)
    end
  end

  describe "#verify" do
    it "calls the post method with the correct parameters" do
      domain_id = "f9d3c1b2-1a2b-4c3d-8e4f-1234567890ab"
      request_body = { type: "dkim" }
      path = "#{api_uri}/v3/admin/domains/#{domain_id}/verify"
      result = [{
        domain_id: domain_id,
        attempt: { type: "dkim" },
        status: "done"
      }, "mock_request_id"]
      allow(domains).to receive(:post)
        .with(path: path, request_body: request_body, headers: signed_headers)
        .and_return(result)

      domain_response = domains.verify(domain_id: domain_id, request_body: request_body,
                                       headers: signed_headers)

      expect(domain_response).to eq(result)
    end
  end

  describe "service account authentication" do
    it "requires all service account request signing headers" do
      unsigned_headers = signed_headers.reject { |key, _| key == "X-Nylas-Signature" }

      expect { domains.list(headers: unsigned_headers) }
        .to raise_error(ArgumentError, /X-Nylas-Signature/)
    end
  end
end
