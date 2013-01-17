require 'rest-client'
require 'json'
require 'addressable/uri'
require 'nokogiri'

class IceCreamFinder
  KEY = "AIzaSyCRxtpeDmx_uUGpiD8hbUJ73ZucaNM1VHQ"

  attr_accessor :places

  def initialize
    @places = []
    @results = nil
    @current_location = nil
    @directions = nil
  end

  def run
    query = get_query
    places_request(query, @current_location)
    print_results
    place_index = get_place_index
    directions_request(@places[place_index]["formatted_address"])
    print_directions
  end

  def get_query # This gets your query and current address, then calls places_request
    puts "What's your address?"
    @current_location = gets.chomp
    puts "What do you want to find?"
    query = gets.chomp
    query
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

    @results = JSON::parse(RestClient.get(address))
    @places = @results["results"] # this peels out all of the actual places that it's found and assigns it to @places
  end

  def print_results # goes through all 
    @places.each_with_index do |place, i|
      puts (i + 1).to_s + ") " + place["name"]
      puts "    " + place["formatted_address"]
      puts "    " + "Rating: " + place["rating"].to_s if !place["rating"].nil?
      puts
    end
  end

  def get_place_index
    puts "Input the number of the place for directions:"
    place_index = gets.chomp.to_i-1
    # places = places_request
    place_index
  end

  def place_names
    @results["results"].map { |place| place["name"] }
  end

  def place_addresses
    @results["results"].map { |place| place["formatted_address"] }
  end

  def directions_request(destination)
    address = Addressable::URI.new(
      :scheme => "http",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json",
      :query_values => {
        :origin => @current_location,
        :destination => destination,
        :sensor => "true",
        :mode => "walking"
      }
    ).to_s

    @directions = JSON::parse(RestClient.get(address))
  end

  def print_directions
    route = @directions["routes"].first["legs"]
    route_directions = route.first["steps"]
    route_directions.each_with_index do |step,i| 
      puts (i +1).to_s + ") " +  Nokogiri::HTML(step["html_instructions"]).text
    end
    nil
  end

end

# d["routes"].first["legs"].first["steps"].each { |step| puts step["html_instructions"]}
# Nokogiri::HTML(html).text
# def x; i = IceCreamFinder.new; i.get_query; i.directions_request("3 Pier #108, San Francisco, CA, United States"); i; end

