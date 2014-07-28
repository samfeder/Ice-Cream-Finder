require 'nokogiri'
require 'addressable/uri'
require 'rest-client'
require 'json'

#gets user location
api_key = nil
begin
  api_key = File.read('.api_key').chomp
rescue
  puts "Unable to read '.api_key'. Please provide a valid Google API key."
  exit
end

puts "Where are you?"
address = gets.chomp


#obtains coordinates
geocode_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/geocode/json",
:query_values => {"address" => address, "key" => api_key}
).to_s

puts geocode_url
location_json = RestClient.get(geocode_url)
location_hash = JSON.parse(location_json)
p latitude = location_hash['results'].first['geometry']['location']['lat']
p longitude = location_hash['results'].first['geometry']['location']['lng']
location_string = "#{latitude},#{longitude}"

#queries places API
url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/place/textsearch/json",
:query_values => {"radius" => 1000, "location" => location_string, "key" => api_key, "query" => "Ice Cream"}
).to_s
p url

places_json = RestClient.get(url)
places = JSON.parse(places_json)

vital_info = []

places["results"].each do |place|
  vital_info << [place['name'], place['formatted_address'], place['geometry']['location']]
end

vital_info.each_with_index do |info, index|
  puts "#{index + 1}: You're close to #{info[0]} at #{info[1]}"
end

puts "Which ice cream shop do you want to go to?"
choice = gets.chomp

dest_latitude = vital_info[choice.to_i - 1][2]['lat']
dest_longitude = vital_info[choice.to_i - 1][2]['lng']
destination_string = "#{dest_latitude},#{dest_longitude}"

#directions API
dest_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/directions/json",
:query_values => {"origin" => location_string,
                  "destination" => destination_string, "key" => api_key}).to_s

directions_json = RestClient.get(dest_url)
directions = JSON.parse(directions_json)

puts "Directions are as follows"
parsed_html_directions = Nokogiri::HTML(directions_json)
puts JSON.parse(parsed_html_directions.text)
