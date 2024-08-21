# frozen_string_literal: true

class CreateGeolocations < ActiveRecord::Migration[7.0]
  def change
    create_table :geolocations do |t|
      t.string :ip_address
      t.string :country_name
      t.string :region_name
      t.string :city
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :geolocations, :ip_address, unique: true
  end
end
