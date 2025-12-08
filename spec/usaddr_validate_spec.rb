require "spec_helper"

RSpec.describe UsaddrValidate do
  it "has a version number" do
    expect(UsaddrValidate::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields configuration" do
      expect { |b| UsaddrValidate.configure(&b) }.to yield_with_args(UsaddrValidate::Configuration)
    end

    it "sets configuration values" do
      UsaddrValidate.configure do |config|
        config.client_id = "test_id"
        config.client_secret = "test_secret"
        config.environment = :test
      end

      expect(UsaddrValidate.configuration.client_id).to eq("test_id")
      expect(UsaddrValidate.configuration.client_secret).to eq("test_secret")
      expect(UsaddrValidate.configuration.environment).to eq(:test)
    end

    it "allows custom field mappings" do
      UsaddrValidate.configure do |config|
        config.street_address = :address_line_1
        config.city = :town
      end

      expect(UsaddrValidate.configuration.street_address).to eq(:address_line_1)
      expect(UsaddrValidate.configuration.city).to eq(:town)
    end
  end

  describe ".reset_configuration" do
    it "resets to default configuration" do
      UsaddrValidate.configure do |config|
        config.client_id = "test_id"
      end

      UsaddrValidate.reset_configuration

      expect(UsaddrValidate.configuration.client_id).to be_nil
      expect(UsaddrValidate.configuration.environment).to eq(:production)
    end
  end
end
