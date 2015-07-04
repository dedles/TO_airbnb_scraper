require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pry'

# store url to be scraped
url = "https://www.airbnb.ca/s/Toronto--ON"

# parse the page with nokogiri
page = Nokogiri::HTML(open(url))

# take the largest number from page_number:
page_numbers = []
page.css("div.pagination ul li a[target]").each do |line|
	page_numbers << line.text.to_i
end

max_page = page_numbers.max

# intialize empty arrays
name = []
price = []
details = []

# loop over each page of search results
max_page.times do |i|

	# open search results page
	url = "https://www.airbnb.ca/s/Toronto--ON?page=#{i+1}"
	page = Nokogiri::HTML(open(url))

	page.css('h3.h5.listing-name').each do |line|
	  name << line.text.strip
	end

	page.css('span.h3.price-amount').each do |line|
		price << line.text
	end

	page.css('div.text-muted.listing-location.text-truncate').each do |line|
		details << line.text.gsub(/(\n|\t|\r)/, ' ').squeeze(' ').strip.split(/ · /)
	end

	# remove extra bullet in nested details array. If there are no reviews add '0 reviews' to space
	details.length.times do |i|
		if details[i][1]
			details[i][1] = details[i][1].gsub(/·/, '').strip
		else
			details[i].push("0 reviews")
		end
	end


end

# Write data to csv file
CSV.open("airbnb_listings.csv", "w") do |file| 
	file << ["Listing Name", "Price", "Room Type", "Reviews"]

	name.length.times do |i| 
		file << [name[i], price[i], details[i][0], details[i][1]]
	end
end


