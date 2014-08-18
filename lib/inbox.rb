require 'version'
require 'rest-client'
require 'restful_model_collection'
require 'json'
require 'namespace'

module Inbox

  class AccessDenied < StandardError; end
  class ResourceNotFound < StandardError; end
  class NoAuthToken < StandardError; end
  class UnexpectedResponse < StandardError; end
  class APIError < StandardError
    attr_accessor :error_type
    def initialize(type, error)
      super(error)
      self.error_type = type
    end
  end

  def self.interpret_response(result, result_content, options = {})
    # Handle HTTP errors and RestClient errors
    raise ResourceNotFound.new if result.code.to_i == 404
    raise AccessDenied.new if result.code.to_i == 403

    # Handle content expectation errors
    raise UnexpectedResponse.new if options[:expected_class] && result_content.empty?
    json = JSON.parse(result_content)
    raise APIError.new(json['type'], json['message']) if json.is_a?(Hash) && json['type'] == 'api_error'
    raise UnexpectedResponse.new(result.msg) if result.is_a?(Net::HTTPClientError)
    raise UnexpectedResponse.new if options[:expected_class] && !json.is_a?(options[:expected_class])
    json

  rescue JSON::ParserError => e
    # Handle parsing errors
    raise UnexpectedResponse.new(e.message)
  end


  class API
    attr_accessor :api_server
    attr_reader :auth_token
    attr_reader :app_id
    attr_reader :app_secret

    def initialize(app_id, app_secret, auth_token = nil, api_server = 'https://api.inboxapp.com')
      raise "When overriding the Inbox API server address, you must include https://" unless api_server.include?('://')
      @api_server = api_server
      @auth_token = auth_token
      @app_secret = app_secret
      @app_id = app_id

      ::RestClient.add_before_execution_proc do |req, params|
        req.add_field('X-Inbox-API-Wrapper', 'ruby')
      end
    end

    def url_for_path(path)
      raise NoAuthToken.new if @auth_token == nil
      protocol, domain = @api_server.split('//')
      "#{protocol}//#{@auth_token}:@#{domain}#{path}"
    end

    def url_for_authentication(redirect_uri, login_hint = '')
      "https://beta.inboxapp.com/oauth/authorize?client_id=#{@app_id}&response_type=code&scope=email&login_hint=#{login_hint}&redirect_uri=#{redirect_uri}"
    end

    def set_auth_token(token)
      @auth_token = token
    end

    def auth_token_for_code(code)
      data = {
          'client_id' => app_id,
          'client_secret' => app_secret,
          'grant_type' => 'authorization_code',
          'code' => code
      }

      ::RestClient.get("#{@api_server}/oauth/token", {:params => data}) do |response, request, result|
        json = Inbox.interpret_response(result, response, :expected_class => Object)
        return json['access_token']
      end
    end

    # Convenience Methods

    def namespaces
      @namespaces ||= RestfulModelCollection.new(Namespace, self)
      @namespaces
    end

  end

end