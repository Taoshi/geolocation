require 'faker'

puts 'Seeding geolocation data...'

10.times do
  Geolocation.create!(
    ip_address: Faker::Internet.ip_v4_address,
    country_name: Faker::Address.country,
    region_name: Faker::Address.state,
    city: Faker::Address.city,
    latitude: Faker::Address.latitude,
    longitude: Faker::Address.longitude
  )
end

puts 'Seeding completed.'
