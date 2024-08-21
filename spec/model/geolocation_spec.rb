require 'spec_helper'

describe Geolocation, type: :model do
  it { should validate_uniqueness_of(:ip_address).case_insensitive }
  it { should validate_presence_of(:country_name) }
  it { should validate_presence_of(:region_name) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:latitude) }
  it { should validate_presence_of(:longitude) }
end
