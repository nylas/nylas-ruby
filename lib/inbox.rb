require 'version'
require 'rest-client'
require 'restful_model_collection'
require 'json'
require 'namespace'

module Inbox

  class AccessDenied < StandardError; end
  class ResourceNotFound < StandardError; end
  class NoAuthToken < StandardError; end
  class UnexpectedAccountAction < StandardError; end
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
    attr_reader :access_token
    attr_reader :app_id
    attr_reader :app_secret

    def initialize(app_id, app_secret, access_token = nil, api_server = 'https://api.inboxapp.com')
      raise "When overriding the Inbox API server address, you must include https://" unless api_server.include?('://')
      @api_server = api_server
      @access_token = access_token
      @app_secret = app_secret
      @app_id = app_id

      ::RestClient.add_before_execution_proc do |req, params|
        req.add_field('X-Inbox-API-Wrapper', 'ruby')
      end
    end

    def url_for_path(path)
      raise NoAuthToken.new if @access_token == nil and (@app_secret != nil or @app_id != nil)
      protocol, domain = @api_server.split('//')
      "#{protocol}//#{@access_token}:@#{domain}#{path}"
    end

    def url_for_authentication(redirect_uri, login_hint = '', options = {})
      trialString = 'false'
      if options[:trial] == true
        trialString = 'true'
      end
      "https://www.inboxapp.com/oauth/authorize?client_id=#{@app_id}&trial=#{trialString}&response_type=code&scope=email&login_hint=#{login_hint}&redirect_uri=#{redirect_uri}"
    end

    def set_access_token(token)
      @access_token = token
    end

    def token_for_code(code)
      data = {
          'client_id' => app_id,
          'client_secret' => app_secret,
          'grant_type' => 'authorization_code',
          'code' => code
      }

      ::RestClient.get("https://www.inboxapp.com/oauth/token", {:params => data}) do |response, request, result|
        json = Inbox.interpret_response(result, response, :expected_class => Object)
        return json['access_token']
      end
    end

    # Convenience Methods

    def namespaces
      @namespaces ||= RestfulModelCollection.new(Namespace, self, nil)
      @namespaces
    end

    # Billing Methods

    def _perform_account_action!(action)
      raise UnexpectedAccountAction.new unless action == "upgrade" || action == "downgrade"

      protocol, domain = @api_server.split('//')
      account_ids = namespaces.all.collect {|n| n.account_id }.uniq
      account_ids.each do | id |
        ::RestClient.post("#{protocol}//#{@app_secret}:@#{domain}/a/#{@app_id}/accounts/#{id}/#{action}",{}) do |response, request, result|
          # Throw any exceptions
          json = Inbox.interpret_response(result, response, :expected_class => Object)
        end
      end
    end

    def upgrade_account!
      _perform_account_action!('upgrade')
    end

    def downgrade_account!
      _perform_account_action!('downgrade')
    end

  end
end
