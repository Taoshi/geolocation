require 'spec_helper'

RSpec.describe Api::V1::GeolocationsController, type: :controller do
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

  before do
    stub_request(:get, "http://api.ipstack.com/#{valid_ip}?access_key=#{ipstack_key}")
      .to_return(status: 200, body: api_response.to_json, headers: { 'Content-Type' => 'application/json' })
  end


  describe 'POST #create' do
    context 'with valid input' do
      it 'creates a new geolocation for a valid IP' do
        post :create, params: { ip_address_or_url: valid_ip }
        expect(response).to have_http_status(201)

        result = JSON.parse(response.body)['result']

        expect(result['city']).to eq('Mountain View')
        expect(result['ip_address']).to eq(valid_ip)
        expect(result['region_name']).to eq('California')
        expect(result['latitude']).to eq("37.386")
        expect(result['longitude']).to eq("-122.084")
      end

      it 'returns an error for an invalid IP' do
        post :create, params: { ip_address_or_url: invalid_ip }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to eq('Parameter ip_address_or_url is invalid')
      end
    end

    context 'with invalid input' do
      it 'returns an error for an invalid URL' do
        post :create, params: { ip_address_or_url: invalid_url }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to eq('Parameter ip_address_or_url is invalid')
      end
    end
  end

  describe 'GET #show' do
    context 'with existing geolocation' do
      it 'returns the geolocation for a valid IP' do

        get :show, params: { ip_address_or_url: valid_ip }

        expect(response).to have_http_status(200)
        result = JSON.parse(response.body)['result']

        expect(result['city']).to eq('Mountain View')
        expect(result['country_name']).to eq('United States')
        expect(result['ip_address']).to eq("8.8.8.8")
        expect(result['latitude']).to eq("37.386")
        expect(result['longitude']).to eq("-122.084")
      end
    end

    context 'with non-existing geolocation' do
      it 'returns a not found error' do
        get :show, params: { ip_address_or_url: '1.1.1.1' }
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['error']).to eq('Geolocation not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with existing geolocation' do
      it 'destroys the geolocation and returns a success message' do
        geolocation = create(:geolocation)
        delete :destroy, params: { ip_address_or_url: geolocation.ip_address }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['result']).to include("Ip address was successfully destroyed #{geolocation.ip_address}")
      end
    end

    context 'with non-existing geolocation' do
      it 'returns a not found error' do
        delete :destroy, params: { ip_address_or_url: '1.1.1.1' }
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['error']).to eq('Geolocation not found')
      end
    end
  end


end
