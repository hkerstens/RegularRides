require 'open-uri'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class UsersController < ApplicationController
  def index
    @users = User.all

  end

  def start
    @user = User.find(current_user[:id])
    @locations = Location.where({:user_id => @user.id})
  end

  def reqs
    @start = params[:start_address]
    @destination = params[:destination_address]
    @current =  params[:current_location]

    if @destination == ""
      if @start =="" && @current.nil?
        redirect_to "/start", :notice => 'Missing start & destination location!!'
      else
        redirect_to "/start", :notice => 'Missing destination location!!'
      end
    else
      if @start =="" && @current.nil?
        redirect_to "/start", :notice => 'Missing start location!'
      else
        if @current.present?
          @lat_start = params[:lat]
          @lng_start = params[:lng]
        else
          url_safe_street_address_start = URI.encode(@start)

          url_start = "http://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address_start}"
          open(url_start)
          raw_data = open(url_start).read

          parsed_data = JSON.parse(open(url_start).read)

          @lat_start = parsed_data["results"][0]["geometry"]["location"]["lat"]

          @lng_start = parsed_data["results"][0]["geometry"]["location"]["lng"]
        end


        url_safe_street_address_dest = URI.encode(@destination)

        url_dest = "http://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address_dest}"
        open(url_dest)
        raw_data = open(url_dest).read

        parsed_data = JSON.parse(open(url_dest).read)

        @lat_destination = parsed_data["results"][0]["geometry"]["location"]["lat"]

        @lng_destination = parsed_data["results"][0]["geometry"]["location"]["lng"]

        if @lat_destination == @lat_start && @lng_start == @lng_destination
          redirect_to "/start", :notice => 'Start and destination are the same, not need for a car!'
        else

          url_dist = "http://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{@lat_start},#{@lng_start}&destinations=#{@lat_destination},#{@lng_destination}"

          open(url_dist)
          raw_data = open(url_dist).read

          parsed_data = JSON.parse(open(url_dist).read)

          @meter = parsed_data["rows"][0]["elements"][0]["distance"]["value"]

          @time = parsed_data["rows"][0]["elements"][0]["duration"]["text"]

          @taxi_price = (3.25 + @meter*0.000621371*1.8).round

          url_uber =
          "https://api.uber.com/v1/estimates/price?start_latitude=#{@lat_start}&start_longitude=#{@lng_start}&end_latitude=#{@lat_destination}&end_longitude=#{@lng_destination}&server_token=9RslzbBhqrEZSdLkLG2oaeNxX_4LCjUF2hfuscqi"

          open(url_uber)
          raw_data = open(url_uber).read

          parsed_data = JSON.parse(open(url_uber).read)

          @uber_price_pool = parsed_data["prices"][0]["estimate"]
          @uber_price_x = parsed_data["prices"][1]["estimate"]

        end
      end
    end
  end
end
