require "spec_helper"

RSpec.describe UsaddrValidate::API do
  before do
    UsaddrValidate.configure do |config|
      config.client_id = "test_client_id"
      config.client_secret = "test_client_secret"
      config.environment = :test
    end
  end

  describe ".validate_address" do
    let(:address_params) do
      {
        street_address: "3120 M St",
        city: "Washington",
        state: "DC",
        zip_code: "20027"
      }
    end

    context "with a valid address" do
      it "returns a successful response", :vcr do
        stub_authentication
        stub_successful_validation

        response = described_class.validate_address(address_params)

        expect(response).to be_a(UsaddrValidate::Response)
        expect(response.success?).to be true
        expect(response.data[:street_address]).to eq("3120 M ST NW")
        expect(response.data[:city]).to eq("WASHINGTON")
        expect(response.data[:state]).to eq("DC")
        expect(response.data[:zip_code]).to eq("20007")
        expect(response.data[:zip_plus4]).to eq("3704")
      end

      it "indicates if address is deliverable" do
        stub_authentication
        stub_successful_validation

        response = described_class.validate_address(address_params)

        expect(response.deliverable?).to be true
        expect(response.dpv_confirmed?).to be true
      end

      it "identifies business addresses" do
        stub_authentication
        stub_successful_validation(business: true)

        response = described_class.validate_address(address_params)

        expect(response.business_address?).to be true
        expect(response.residential_address?).to be false
      end
    end

    context "with an invalid address" do
      it "returns an error response" do
        stub_authentication
        stub_failed_validation

        response = described_class.validate_address(address_params)

        expect(response.success?).to be false
        expect(response.error).not_to be_nil
        expect(response.message).to include("validation failed")
      end
    end

    context "with authentication failure" do
      it "returns an error response" do
        stub_failed_authentication

        response = described_class.validate_address(address_params)

        expect(response.success?).to be false
        expect(response.error).to include("AuthenticationError")
      end
    end
  end

  describe ".validate" do
    it "is an alias for validate_address" do
      expect(described_class.method(:validate)).to eq(described_class.method(:validate_address))
    end
  end

  private

  def stub_authentication
    stub_request(:post, "https://api-cat.usps.com/oauth2/v3/token")
      .with(
        body: hash_including({
          "client_id" => "test_client_id",
          "client_secret" => "test_client_secret",
          "grant_type" => "client_credentials"
        })
      )
      .to_return(
        status: 200,
        body: {
          access_token: "test_token_123",
          token_type: "Bearer",
          expires_in: 3600,
          scope: "addresses"
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_failed_authentication
    stub_request(:post, "https://api-cat.usps.com/oauth2/v3/token")
      .to_return(status: 401, body: "Unauthorized")
  end

  def stub_successful_validation(business: false)
    stub_request(:get, "https://api-cat.usps.com/addresses/v3/address")
      .with(
        query: hash_including({
          "streetAddress" => "3120 M St",
          "city" => "Washington",
          "state" => "DC",
          "ZIPCode" => "20027"
        }),
        headers: { 'Authorization' => 'Bearer test_token_123' }
      )
      .to_return(
        status: 200,
        body: {
          address: {
            streetAddress: "3120 M ST NW",
            city: "WASHINGTON",
            state: "DC",
            ZIPCode: "20007",
            ZIPPlus4: "3704"
          },
          additionalInfo: {
            deliveryPoint: "20",
            DPVConfirmation: "Y",
            business: business ? "Y" : "N"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_failed_validation
    stub_request(:get, "https://api-cat.usps.com/addresses/v3/address")
      .to_return(
        status: 400,
        body: { error: "Address validation failed" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
