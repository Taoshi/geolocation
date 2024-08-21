require 'spec_helper'

RSpec.describe GeolocationService, type: :service do
  let(:valid_ip) { '8.8.8.8' }
  let(:valid_url) { 'https://www.google.com' }
  let(:invalid_ip) { '999.999.999.999' }
  let(:invalid_url) { 'invalid_url' }
  let(:ipstack_key) { ENV['IPSTACK_API_KEY'] }

  let(:api_response) do
    {
      'country_name' => 'United States',
      'region_name' => 'California',
      'city' => 'Mountain View',
      'latitude' => 37.386,
      'longitude' => -122.084,
      'ip' => valid_ip
    }
  end

  describe '#initialize' do
    it 'assigns input and find_in_db correctly' do
      service = described_class.new(valid_ip, find_in_db: true)
      expect(service.input).to eq(valid_ip)
      expect(service.find_in_db).to be true
    end

    it 'defaults find_in_db to false' do
      service = described_class.new(valid_ip)
      expect(service.find_in_db).to be false
    end
  end

  describe '#call' do
    context 'when input is invalid' do
      it 'returns an error for invalid IP' do
        result = described_class.new(invalid_ip).call
        expect(result.success?).to be false
        expect(result.error).to eq('Parameter ip_address_or_url is invalid')
      end

      it 'returns an error for invalid URL' do
        result = described_class.new(invalid_url).call
        expect(result.success?).to be false
        expect(result.error).to eq('Parameter ip_address_or_url is invalid')
      end
    end

    context 'when input is valid' do
      before do
        stub_request(:get, "http://api.ipstack.com/#{valid_ip}?access_key=#{ipstack_key}")
          .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'fetches geolocation data for valid IP' do
        geolocation = create(:geolocation)

        result = described_class.new(geolocation.ip_address, find_in_db: true).call

        expect(result.success?).to be true
        expect(result.object.city).to eq('Mountain View')
      end


      it 'fetches data from the database if find_in_db is true' do
        geolocation = create(:geolocation)
        result = described_class.new(geolocation.ip_address, find_in_db: true).call

        expect(result.success?).to be true
        expect(result.object).to eq(geolocation)
      end
    end
  end
end
