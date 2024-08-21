# frozen_string_literal: true

class Geolocation < ApplicationRecord
  validates :ip_address, uniqueness: { case_sensitive: false }
  validates :country_name, :region_name, :city, :latitude, :longitude, presence: true
end
