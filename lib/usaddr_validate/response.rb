module UsaddrValidate
  class Response
    attr_reader :raw_data, :error, :message

    def initialize(data: nil, error: nil, message: nil)
      @raw_data = data
      @error = error
      @message = message || (success? ? "Address validated successfully" : "Address validation failed")
    end

    def success?
      @error.nil? && @raw_data && @raw_data["address"]
    end

    def data
      return nil unless success?

      address = @raw_data["address"]
      additional_info = @raw_data["additionalInfo"] || {}

      {
        street_address: address["streetAddress"],
        secondary_address: address["secondaryAddress"],
        city: address["city"],
        state: address["state"],
        zip_code: address["ZIPCode"],
        zip_plus4: address["ZIPPlus4"],
        delivery_point: additional_info["deliveryPoint"],
        carrier_route: additional_info["carrierRoute"],
        dpv_confirmation: additional_info["DPVConfirmation"],
        business: additional_info["business"] == "Y",
        vacant: additional_info["vacant"] == "Y"
      }.compact
    end

    # Convenience methods for common checks
    def deliverable?
      success? && dpv_confirmed?
    end

    def dpv_confirmed?
      data && data[:dpv_confirmation] == "Y"
    end

    def business_address?
      data && data[:business] == true
    end

    def residential_address?
      data && data[:business] == false
    end

    def to_h
      {
        success: success?,
        data: data,
        error: error,
        message: message
      }
    end
  end
end
