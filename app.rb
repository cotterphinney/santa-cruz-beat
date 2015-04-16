require 'sinatra'
require 'sinatra/activerecord'
require 'active_record'
require 'json'
require './environments'

class Concert < ActiveRecord::Base
	def local_date_time
		DateTime.parse(self.date.to_s).strftime("%a %m/%d %l:%M %p")
	end

  def truncated_description
    return self.description[0..100] + "..." unless self.description.nil?
    return self.description
  end
end

get '/' do
	erb :index
end

get '/concerts' do
	@concerts = Concert.order(date: :asc)
	erb :concerts
end

get '/api/concerts' do
	@concerts = Concert.order(date: :asc).to_json
end

get '/api/concerts/:id' do
  concert = Concert.find(params[:id])
  return status 404 if concert.nil?
  concert.to_json
end