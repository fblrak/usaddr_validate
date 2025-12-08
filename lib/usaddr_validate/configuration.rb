module UsaddrValidate
  class Configuration
    attr_accessor :client_id, :client_secret, :environment, :timeout
    attr_accessor :street_address, :secondary_address, :city, :state, :zip_code, :zip_plus4

    def initialize
      @environment = :production
      @timeout = 30

      # Field name mappings (allows customization like the old gem)
      @street_address = :street_address
      @secondary_address = :secondary_address
      @city = :city
      @state = :state
      @zip_code = :zip_code
      @zip_plus4 = :zip_plus4
    end

    def base_url
      case environment
      when :production
        "https://apis.usps.com"
      when :test, :development
        "https://api-cat.usps.com"
      else
        raise ConfigurationError, "Invalid environment: #{environment}. Use :production or :test"
      end
    end

    def valid?
      client_id && client_secret
    end
  end
end
