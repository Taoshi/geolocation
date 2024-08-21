FactoryBot.define do
  factory :geolocation do
    sequence(:ip_address) { |n| "192.168.1.#{n}" }
    country_name { "United States" }
    region_name { "California" }
    city { "Mountain View" }
    latitude { 37.386 }
    longitude { -122.0838 }
  end
end
