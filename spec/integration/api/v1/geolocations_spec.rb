
require 'swagger_helper'
require 'spec_helper'

RSpec.describe 'API V1 Geolocations', type: :request do

  path '/api/v1/geolocations' do
    post 'Create a Geolocation' do
      tags 'Geolocations'
      consumes 'application/json'
      parameter name: :geolocation, in: :body, schema: {
        type: :object,
        properties: {
          ip_address_or_url: { type: :string, default: '1.1.1.1' }
        },
        required: ['ip_address_or_url']
      }

      response '201', 'geolocation created' do
        let(:geolocation) { { ip_address_or_url: Faker::Internet.unique.ip_v4_address } }

        before do
          stub_request(:get, "http://api.ipstack.com/#{geolocation[:ip_address_or_url]}")
            .with(query: { access_key: ENV['IPSTACK_API_KEY'] })
            .to_return(
              status: 200,
              body: {
                'ip' => geolocation[:ip_address_or_url],
                'country_name' => 'United States',
                'region_name' => 'California',
                'city' => 'Mountain View',
                'latitude' => 37.386,
                'longitude' => -122.084
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['result']).to include('ip_address', 'country_name', 'city', 'latitude', 'longitude')
        end
      end


      response '422', 'invalid input' do
        let(:geolocation) { { ip_address_or_url: 'invalid_ip' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Parameter ip_address_or_url is invalid')
        end
      end
    end
  end

  path '/api/v1/geolocations' do
    get 'Show a Geolocation' do
      tags 'Geolocations'
      produces 'application/json'
      parameter name: :ip_address_or_url, in: :query, type: :string, description: 'IP Address or URL to fetch the geolocation', default: '1.1.1.1'

      response '200', 'geolocation found' do
        let(:ip_address_or_url) { '8.8.8.8' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['result']).to include('ip_address', 'country_name', 'city', 'latitude', 'longitude')
        end
      end

      response '404', 'geolocation not found' do
        let(:ip_address_or_url) { '1.2.3.4' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/geolocations' do
    delete 'Delete a Geolocation' do
      tags 'Geolocations'
      parameter name: :ip_address_or_url, in: :query, type: :string, description: 'IP Address or URL to delete the geolocation', default: '1.1.1.1'
      produces 'application/json'

      response '200', 'geolocation deleted' do
        let(:ip_address_or_url) { '8.8.8.8' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['result']).to include('Ip address was successfully destroyed')
        end
      end

      response '404', 'geolocation not found' do
        let(:ip_address_or_url) { 'invalid_ip_or_url' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
