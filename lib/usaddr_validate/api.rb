module UsaddrValidate
  class API
    class << self
      def validate_address(params)
        client = Client.new
        raw_data = client.validate_address(params)
        Response.new(data: raw_data)
      rescue AuthenticationError, ValidationError, Error => e
        Response.new(error: e.class.name, message: e.message)
      end

      # Alias for compatibility
      def validate(params)
        validate_address(params)
      end
    end
  end
end
