require 'httparty'
require "awesome_print"
require 'dotenv'

Dotenv.load

LOCATION_IQ_KEY = ENV['LoIQ_TOKEN']
BASE_URL = "https://us1.locationiq.com/v1/search.php"

class InvalidSearch < StandardError 
end

def get_location(search_term)
  url = BASE_URL
  query_items = { q: search_term,
            key: LOCATION_IQ_KEY,
            format: "json" }
  response = HTTParty.get(url, query: query_items)
  
  raise InvalidSearch.new("Invalid search #{ response.code }") unless response.code != "200"
  
  return {"#{search_term}" => {:lat => response.first["lat"], :lon => response.first["lon"]}}
end

def find_seven_wonders

  seven_wonders = ["Great Pyramid of Giza", "Gardens of Babylon", "Colossus of Rhodes", "Pharos of Alexandria", "Statue of Zeus at Olympia", "Temple of Artemis", "Mausoleum at Halicarnassus"]

  seven_wonders_locations = []

  seven_wonders.each do |wonder|
    sleep(0.5)
    seven_wonders_locations << get_location(wonder)
  end

  return seven_wonders_locations
end

# Use awesome_print because it can format the output nicely
ap find_seven_wonders



# Expecting something like:
# [{"Great Pyramid of Giza"=>{:lat=>"29.9791264", :lon=>"31.1342383751015"}}, {"Gardens of Babylon"=>{:lat=>"50.8241215", :lon=>"-0.1506162"}}, {"Colossus of Rhodes"=>{:lat=>"36.3397076", :lon=>"28.2003164"}}, {"Pharos of Alexandria"=>{:lat=>"30.94795585", :lon=>"29.5235626430011"}}, {"Statue of Zeus at Olympia"=>{:lat=>"37.6379088", :lon=>"21.6300063"}}, {"Temple of Artemis"=>{:lat=>"32.2818952", :lon=>"35.8908989553238"}}, {"Mausoleum at Halicarnassus"=>{:lat=>"37.03788265", :lon=>"27.4241455276707"}}]


# Optional1 - Make a request for driving directions
BASE_URL2 = 'https://us1.locationiq.com/v1/'

def request_a_driving_directions(a_place, b_place)
  url = BASE_URL2
  a_coordination = get_location(a_place)
  b_coordination = get_location(b_place)
  query_items = { service: "directions",
            profile: "driving",
            coordinates: "#{a_coordination[a_place][:lon]}, #{a_coordination[a_place][:lat]}; #{b_coordination[b_place][:lon]}, #{b_coordination[b_place][:lat]}",
            key: LOCATION_IQ_KEY}
  response = HTTParty.get(url, query: query_items)
  
  raise InvalidSearch.new("Invalid search #{ response.code }") unless response.code != "200"
  
  return response
end

pp request_a_driving_directions('Cairo Egypt', 'Great Pyramid of Giza')

puts
# Optional2 - Turn locations into the names of places
BASE_URL3 = 'https://us1.locationiq.com/v1/reverse.php'

def find_a_place(lat_info, lon_info)
  url = BASE_URL3
  query_items = {
    lat: lat_info,
    lon: lon_info,
    key: LOCATION_IQ_KEY,
    format: 'json'
  }
  response = HTTParty.get(url, query: query_items)
  
  raise InvalidSearch.new("Invalid search #{ response.code }") unless response.code != "200"
  
  return response["display_name"]
end

plases_to_find = [{ lat: 38.8976998, lon: -77.0365534886228}, {lat: 48.4283182, lon: -123.3649533 }, { lat: 41.8902614, lon: 12.493087103595503}]

plases_to_find.each do |place|
  puts "#{ place[:lat] } & #{ place[:lon] } is \"#{ find_a_place(place[:lat], place[:lon]) }\""
end