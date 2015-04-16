require 'eventful/api'
require 'sanitize'

eventful = Eventful::API.new 'KmhZfDM4PgcQhv57'

results = eventful.call 'events/search',
           :location => "Santa Cruz, CA",
           :date => "2015032900-2015033000",
           :category => "music",
           :page_size => 200

results['events']['event'].each do |event|
   link = "http://eventful.com/events/" + event['id']
   title = event['title']
   venue = event['venue_name']
   time = event['start_time'].to_s if event['start_time']
   description = Sanitize.fragment(event['description']).strip!
 end