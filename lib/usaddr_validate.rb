require_relative "usaddr_validate/version"
require_relative "usaddr_validate/configuration"
require_relative "usaddr_validate/client"
require_relative "usaddr_validate/api"
require_relative "usaddr_validate/response"

module UsaddrValidate
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ValidationError < Error; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def reset_configuration
      self.configuration = Configuration.new
    end
  end
end
