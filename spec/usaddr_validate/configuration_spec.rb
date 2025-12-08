require "spec_helper"

RSpec.describe UsaddrValidate::Configuration do
  let(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.environment).to eq(:production)
      expect(config.timeout).to eq(30)
      expect(config.street_address).to eq(:street_address)
      expect(config.city).to eq(:city)
      expect(config.state).to eq(:state)
      expect(config.zip_code).to eq(:zip_code)
    end
  end

  describe "#base_url" do
    context "when environment is production" do
      it "returns production URL" do
        config.environment = :production
        expect(config.base_url).to eq("https://apis.usps.com")
      end
    end

    context "when environment is test" do
      it "returns test URL" do
        config.environment = :test
        expect(config.base_url).to eq("https://api-cat.usps.com")
      end
    end

    context "when environment is invalid" do
      it "raises an error" do
        config.environment = :invalid
        expect { config.base_url }.to raise_error(/Invalid environment/)
      end
    end
  end

  describe "#valid?" do
    it "returns false without credentials" do
      expect(config.valid?).to be false
    end

    it "returns true with credentials" do
      config.client_id = "test_id"
      config.client_secret = "test_secret"
      expect(config.valid?).to be true
    end
  end
end
