# frozen_string_literal: true

require 'socket'
require 'uri'
require 'httparty'

class GeolocationService
  include HTTParty
  base_uri 'http://api.ipstack.com/'
  attr_reader :input, :find_in_db

  ResponseData = Struct.new(:success?, :object, :error)

  def initialize(input, find_in_db: false)
    @input = input
    @find_in_db = find_in_db
  end

  def call
    return build_response('Parameter ip_address_or_url is blank') if input.blank?
    return build_response('Parameter ip_address_or_url is invalid') unless valid_ip?(input) || valid_url?(input)
    return build_response('Provide IPSTACK_API_KEY') if ENV['IPSTACK_API_KEY'].blank?

    find_in_db ? fetch_from_db(input) : lookup(input)
  end

  private

  def lookup(input)
    response = get_ip_from_input(input)

    fetch_geolocation(response)
  end

  def get_ip_from_input(input)
    valid_ip?(input) ? input : resolve_ip_from_url(input)
  end

  def valid_ip?(ip)
    IPAddress.valid?(ip)
  rescue StandardError
    false
  end

  def valid_url?(url)
    uri = URI.parse(url)
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    host = uri.host
    return false if host.nil?

    begin
      Socket.getaddrinfo(host, nil, Socket::AF_INET)
      true
    rescue SocketError
      false
    end
  end

  def resolve_ip_from_url(url)
    host = URI.parse(url).host
    Socket.getaddrinfo(host, nil, Socket::AF_INET)[0][3]
  rescue SocketError => e
    build_response("Unable to resolve IP from URL: #{e.message}")
  end

  def fetch_from_db(input)
    ip_address = get_ip_from_input(input)
    geolocation = Geolocation.find_by(ip_address:)
    build_response(geolocation)
  end

  def fetch_geolocation(ip_address)
    response = self.class.get("/#{ip_address}?access_key=#{ENV.fetch('IPSTACK_API_KEY', nil)}")

    if response.success?
      data = {
        country_name: response['country_name'],
        region_name: response['region_name'],
        city: response['city'],
        latitude: response['latitude'],
        longitude: response['longitude'],
        ip_address: response['ip']
      }

      geolocation = Geolocation.create(data)
      build_response(geolocation)
    end
  rescue StandardError => e
    Rails.logger.info("Failed to fetch geolocation data: #{e}")
    build_response('URI is invalid')
  end

  def build_response(response)
    if response.respond_to?(:valid?)
      ResponseData.new(success?: response.valid?, object: response, error: response.errors.full_messages.to_sentence)
    elsif response.is_a?(String)
      ResponseData.new(success?: false, object: nil, error: response)
    else
      ResponseData.new(success?: false, object: nil, error: nil)
    end
  end
end
