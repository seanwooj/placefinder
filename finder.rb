require 'rest-client'
require 'json'
require 'addressable/uri'
require 'nokogiri'

class PlaceFinder
  KEY = "AIzaSyCRxtpeDmx_uUGpiD8hbUJ73ZucaNM1VHQ"

  def initialize
    run
  end

  def run
    current_location = get_current_loc
    query = get_query
    puts
    places =  places_request(query, current_location)
    print_results(places)
    place_index = get_place_index
    directions = directions_request(places[place_index]["formatted_address"], current_location)
    print_directions(directions)
  end

  def get_query # This gets your query and current address, then calls places_request
    print "What do you want to find? > "
    gets.chomp
  end

  def get_current_loc
    print "What's your address? > "
    gets.chomp
  end

  def places_request(query,address) # this takes in your query and address and returns the .json
    address = Addressable::URI.new( # file with the data you requested and assigns it to @results
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/textsearch/json",
      :query_values => {
        :query => "#{query} #{address}",
        :sensor => "true",
        :key => KEY
      }
    ).to_s

    results = JSON::parse(RestClient.get(address))
    results["results"] # this peels out all of the actual places that it's found
  end

  def print_results(places) # goes through all 
    places.each_with_index do |place, i|
      puts (i + 1).to_s + ") " + place["name"]
      puts "    " + place["formatted_address"]
      puts "    " + "Rating: " + place["rating"].to_s if !place["rating"].nil?
      puts
    end
  end

  def get_place_index
    print "Input the number of the place for directions > "
    place_index = gets.chomp.to_i-1
    puts
    place_index
  end

  def directions_request(destination, current_location)
    address = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
        :origin => current_location,
        :destination => destination,
        :sensor => "true",
        :mode => "walking"
      }
    ).to_s

    JSON::parse(RestClient.get(address))
  end

  def print_directions(directions)
    route = directions["routes"].first["legs"]
    route_directions = route.first["steps"]
    route_directions.each_with_index do |step,i| 
      puts (i +1).to_s + ") " +  Nokogiri::HTML(step["html_instructions"] + " - " + step["distance"]["text"]).text
    end
    nil
  end
end

