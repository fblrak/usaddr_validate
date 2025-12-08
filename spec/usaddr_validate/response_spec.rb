require "spec_helper"

RSpec.describe UsaddrValidate::Response do
  describe "#success?" do
    it "returns true when data is present and no error" do
      response = described_class.new(
        data: { "address" => { "streetAddress" => "123 Main St" } }
      )
      expect(response.success?).to be true
    end

    it "returns false when error is present" do
      response = described_class.new(error: "Some error")
      expect(response.success?).to be false
    end

    it "returns false when data is missing" do
      response = described_class.new(data: nil)
      expect(response.success?).to be false
    end
  end

  describe "#data" do
    let(:raw_data) do
      {
        "address" => {
          "streetAddress" => "3120 M ST NW",
          "city" => "WASHINGTON",
          "state" => "DC",
          "ZIPCode" => "20007",
          "ZIPPlus4" => "3704"
        },
        "additionalInfo" => {
          "deliveryPoint" => "20",
          "DPVConfirmation" => "Y",
          "business" => "Y"
        }
      }
    end

    it "returns formatted address data" do
      response = described_class.new(data: raw_data)
      data = response.data

      expect(data[:street_address]).to eq("3120 M ST NW")
      expect(data[:city]).to eq("WASHINGTON")
      expect(data[:state]).to eq("DC")
      expect(data[:zip_code]).to eq("20007")
      expect(data[:zip_plus4]).to eq("3704")
      expect(data[:delivery_point]).to eq("20")
      expect(data[:dpv_confirmation]).to eq("Y")
      expect(data[:business]).to be true
    end

    it "returns nil when response is not successful" do
      response = described_class.new(error: "Error")
      expect(response.data).to be_nil
    end
  end

  describe "#deliverable?" do
    it "returns true for confirmed deliverable addresses" do
      raw_data = {
        "address" => { "streetAddress" => "123 Main St" },
        "additionalInfo" => { "DPVConfirmation" => "Y" }
      }
      response = described_class.new(data: raw_data)
      expect(response.deliverable?).to be true
    end

    it "returns false for unconfirmed addresses" do
      raw_data = {
        "address" => { "streetAddress" => "123 Main St" },
        "additionalInfo" => { "DPVConfirmation" => "N" }
      }
      response = described_class.new(data: raw_data)
      expect(response.deliverable?).to be false
    end
  end

  describe "#business_address?" do
    it "returns true for business addresses" do
      raw_data = {
        "address" => { "streetAddress" => "123 Main St" },
        "additionalInfo" => { "business" => "Y" }
      }
      response = described_class.new(data: raw_data)
      expect(response.business_address?).to be true
    end

    it "returns false for residential addresses" do
      raw_data = {
        "address" => { "streetAddress" => "123 Main St" },
        "additionalInfo" => { "business" => "N" }
      }
      response = described_class.new(data: raw_data)
      expect(response.business_address?).to be false
    end
  end

  describe "#to_h" do
    it "returns a hash representation" do
      response = described_class.new(
        data: { "address" => { "streetAddress" => "123 Main St" } },
        message: "Success"
      )
      hash = response.to_h

      expect(hash).to include(:success, :data, :error, :message)
      expect(hash[:success]).to be true
      expect(hash[:message]).to eq("Success")
    end
  end
end
