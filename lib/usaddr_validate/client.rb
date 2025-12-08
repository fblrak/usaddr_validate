require "faraday"
require "faraday/retry"
require "json"

module UsaddrValidate
  class Client
    attr_reader :config, :access_token, :token_expires_at

    def initialize(config = nil)
      @config = config || UsaddrValidate.configuration
      raise ConfigurationError, "Configuration not set" unless @config&.valid?

      @access_token = nil
      @token_expires_at = nil
    end

    def validate_address(params)
      ensure_authenticated!

      query_params = build_query_params(params)
      response = connection.get("/addresses/v3/address", query_params) do |req|
        req.headers["Authorization"] = "Bearer #{@access_token}"
        req.headers["Accept"] = "application/json"
      end

      handle_response(response)
    end

    private

    def ensure_authenticated!
      return if token_valid?
      authenticate!
    end

    def token_valid?
      @access_token && @token_expires_at && Time.now < @token_expires_at
    end

    def authenticate!
      response = connection.post("/oauth2/v3/token") do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = {
          client_id: @config.client_id,
          client_secret: @config.client_secret,
          grant_type: "client_credentials"
        }.to_json
      end

      if response.success?
        data = JSON.parse(response.body)
        @access_token = data["access_token"]
        # Subtract 60 seconds to ensure we refresh before expiration
        @token_expires_at = Time.now + data["expires_in"].to_i - 60
      else
        raise AuthenticationError, "Failed to authenticate with USPS API: #{response.status} - #{response.body}"
      end
    rescue JSON::ParserError => e
      raise AuthenticationError, "Invalid authentication response: #{e.message}"
    end

    def build_query_params(params)
      {
        streetAddress: params[@config.street_address] || params[:street_address],
        secondaryAddress: params[@config.secondary_address] || params[:secondary_address],
        city: params[@config.city] || params[:city],
        state: params[@config.state] || params[:state],
        ZIPCode: params[@config.zip_code] || params[:zip_code],
        ZIPPlus4: params[@config.zip_plus4] || params[:zip_plus4]
      }.compact
    end

    def handle_response(response)
      case response.status
      when 200
        JSON.parse(response.body)
      when 400
        error_data = JSON.parse(response.body) rescue {}
        raise ValidationError, "Invalid address data: #{error_data['error'] || response.body}"
      when 401
        raise AuthenticationError, "Authentication failed"
      when 404
        raise ValidationError, "Address not found"
      else
        raise Error, "USPS API error: #{response.status} - #{response.body}"
      end
    rescue JSON::ParserError => e
      raise Error, "Invalid response from USPS API: #{e.message}"
    end

    def connection
      @connection ||= Faraday.new(url: @config.base_url) do |conn|
        conn.options.timeout = @config.timeout
        conn.options.open_timeout = 10
        conn.request :retry, {
          max: 2,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          retry_statuses: [500, 502, 503, 504],
          methods: [:get, :post]
        }
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
