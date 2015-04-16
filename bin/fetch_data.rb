require 'nokogiri'
require 'open-uri'
require 'chronic'
require 'date'
require './app'
require 'eventful/api'
require 'sanitize'

@concerts = []

def add_concert(title, venue, link, date, description=nil)
	@concerts << {
		title: title,
		venue: venue,
		link: link,
		date: date,
		description: description
	}
end

def fetch_eventful_concerts(from_date, to_date)
	while from_date != to_date
		formatted_from_date = from_date.strftime('%Y%m%d00') #eventful api makes us append two 0s to dates for some reason
		puts formatted_from_date

		eventful = Eventful::API.new 'KmhZfDM4PgcQhv57'
		results = eventful.call 'events/search',
		           :location => "Santa Cruz, CA",
		           :date => "#{formatted_from_date}-#{formatted_from_date}",
		           :category => "music",
		           :page_size => 200

		unless results['events'].nil?
			results['events']['event'].each do |event|
				next if event.length < 3
				link = "http://eventful.com/events/" + event['id']
				title = event['title']
				venue = event['venue_name']
				date = event['start_time'].to_s if event['start_time']
				description = Sanitize.fragment(event['description']).strip!
				add_concert(title, venue, link, date, description)
			end
		end

		from_date += 1
	end
end

def fetch_ticketfly_concerts(venues)
	venues.each do |venue|
		doc = Nokogiri::XML(open("http://www.ticketfly.com/api/events/upcoming.rss?venueId=#{venue}"))
		doc.xpath("//item").each do |i|
			event = i.xpath('title').text
			# the title includes the date and time, so we remove it
			event = event.split(" ")[0..-6].join(" ").split(" at ")
			venue = event.pop
			title = event.join(" ")
			link = i.xpath('link').text
			# dates/times are stored in GMT so we have to convert to local time
			date = DateTime.strptime(i.xpath('pubDate').text, "%a, %d %b %Y %H:%M:%S %Z")
			add_concert(title, venue, link, date)
		end
	end
end

def fetch_crepe_place_concerts
	page = Nokogiri::HTML(open("http://thecrepeplace.com/events/"))
	events = page.css('li.clear')
	events.each do |event|
		venue = "The Crepe Place"
		date = event.at_css('div.date')['title']
		date = Chronic.parse(date)
		title = event.at_css('h3 a').text
		path = event.at_css('h3 a')['href']
		link = "http://thecrepeplace.com#{path}"
		description = event.at_css('p').text.strip!
		add_concert(title, venue, link, date, description)
	end
end

def store_results(concerts)
	concerts.each do |c|
		Concert.create(title: c[:title], venue: c[:venue], link: c[:link], date: c[:date], description: c[:description])
	end
end

now = DateTime.now
Concert.delete_all
fetch_eventful_concerts(now, now + 60)
store_results(@concerts)