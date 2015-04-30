require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
require 'json'
require 'date'
require 'chronic'
require './environments'

class Concert < ActiveRecord::Base
	def local_date_time
		DateTime.parse(self.date.to_s).strftime("%l:%M %p")
	end

  def truncated_description
    return self.description[0..50] + "..." unless self.description.nil?
    return self.description
  end
end

get '/' do
  @concerts = Concert.order(date: :asc)
  if params['from_date'] && params['to_date']
    from_date = Chronic.parse(params['from_date']+' 00:00:00')
    to_date = Chronic.parse(params['to_date']+' 24:00:00')
    @concerts = @concerts.where("date >= ? AND date <= ?", from_date, to_date)
  end
  @concert_days = @concerts.group_by { |c| DateTime.parse(c.date.to_s).strftime("%Y/%m/%d") }
	erb :concerts
end

# get '/concerts' do
# 	@concerts = Concert.order(date: :asc)
# 	erb :concerts
# end

get '/api/concerts' do
	concerts = Concert.order(date: :asc)
  if params['from_date'] && params['to_date']
    from_date = Chronic.parse(params['from_date'])
    to_date = Chronic.parse(params['to_date'])
    concerts = concerts.where("date >= ? AND date <= ?", from_date, to_date)
  end
  return concerts.to_json
end

get '/api/concerts/:id' do
  concert = Concert.find(params[:id])
  return status 404 if concert.nil?
  concert.to_json
end

# get '/api/concerts/'