# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require "securerandom"

module Nylas
  # Builds Nylas Service Account request signing headers for organization admin APIs.
  #
  # @see https://developer.nylas.com/docs/v3/auth/nylas-service-account/
  class ServiceAccountSigner
    NONCE_ALPHABET = ("a".."z").to_a.concat(("A".."Z").to_a, ("0".."9").to_a).freeze
    DEFAULT_NONCE_LENGTH = 20
    SIGNED_BODY_METHODS = %w[post put patch].freeze

    attr_reader :private_key_id

    # @param private_key_pem [String] RSA private key in PEM format.
    # @param private_key_id [String] Value for the X-Nylas-Kid header.
    def initialize(private_key_pem:, private_key_id:)
      @private_key = self.class.load_rsa_private_key(private_key_pem)
      @private_key_id = private_key_id
    end

    # Returns deterministic JSON with keys sorted at every object level and no extra whitespace.
    #
    # @param data [Hash, Array, String, Numeric, true, false, nil] Data to serialize.
    # @return [String] Canonical JSON string.
    def self.canonical_json(data)
      JSON.generate(canonicalize(data))
    end

    # Loads an RSA private key from a PEM string.
    #
    # @param private_key_pem [String] RSA private key in PEM format.
    # @return [OpenSSL::PKey::RSA]
    def self.load_rsa_private_key(private_key_pem)
      key = OpenSSL::PKey::RSA.new(private_key_pem)
      raise ArgumentError, "Private key must be RSA private key" unless key.private?
      raise ArgumentError, "Private key must be at least 2048 bits" if key.n.num_bits < 2048

      key
    rescue OpenSSL::PKey::PKeyError
      raise ArgumentError, "Private key must be RSA PEM"
    end

    # Generates a cryptographically secure alphanumeric nonce.
    #
    # @param length [Integer] Length of the nonce to generate.
    # @return [String] Generated nonce.
    def self.generate_nonce(length = DEFAULT_NONCE_LENGTH)
      Array.new(length) { NONCE_ALPHABET[SecureRandom.random_number(NONCE_ALPHABET.length)] }.join
    end

    # Builds signed headers and, for JSON body methods, the exact canonical body to send.
    #
    # @param method [String, Symbol] HTTP method.
    # @param path [String] Relative request path, for example "/v3/admin/domains".
    # @param body [Hash, nil] Request body for POST/PUT/PATCH requests.
    # @param timestamp [Integer, nil] Optional Unix timestamp in seconds, mainly for tests.
    # @param nonce [String, nil] Optional nonce, mainly for tests.
    # @return [Array(Hash, String)] Signed headers and optional serialized JSON body.
    def build_headers(method:, path:, body: nil, timestamp: nil, nonce: nil)
      timestamp ||= Time.now.to_i
      nonce ||= self.class.generate_nonce
      method_value = method.to_s.downcase
      serialized_body = nil

      if SIGNED_BODY_METHODS.include?(method_value) && !body.nil?
        serialized_body = self.class.canonical_json(body)
      end

      envelope = {
        method: method_value,
        nonce: nonce,
        path: path,
        timestamp: timestamp
      }
      envelope[:payload] = serialized_body if serialized_body

      signature = @private_key.sign(OpenSSL::Digest.new("SHA256"), self.class.canonical_json(envelope))

      [
        {
          "X-Nylas-Kid" => private_key_id,
          "X-Nylas-Nonce" => nonce,
          "X-Nylas-Timestamp" => timestamp.to_s,
          "X-Nylas-Signature" => Base64.strict_encode64(signature)
        },
        serialized_body
      ]
    end

    class << self
      private

      def canonicalize(value)
        case value
        when Hash
          value.keys.sort_by(&:to_s).each_with_object({}) do |key, result|
            result[key.to_s] = canonicalize(value[key])
          end
        when Array
          value.map { |item| canonicalize(item) }
        else
          value
        end
      end
    end
  end
end
