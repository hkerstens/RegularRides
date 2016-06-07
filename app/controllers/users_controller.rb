require 'open-uri'
require 'json'

class UsersController < ApplicationController
  def index
    @users = User.all

  end

  def show
    @user = User.find(params[:id])
  end

  def start
    @user = User.find(current_user[:id])
    @locations = Location.where({:user_id => @user.id})
  end

  def reqs
    @start = params[:start_address]
    @destination = params[:destination_address]

    url_safe_street_address_start = URI.encode(@start)

    url_start = "http://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address_start}"
    open(url_start)
    raw_data = open(url_start).read

    parsed_data = JSON.parse(open(url_start).read)

    @lat_start = parsed_data["results"][0]["geometry"]["location"]["lat"]

    @lng_start = parsed_data["results"][0]["geometry"]["location"]["lng"]

    url_safe_street_address_dest = URI.encode(@destination)

    url_dest = "http://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address_dest}"
    open(url_dest)
    raw_data = open(url_dest).read

    parsed_data = JSON.parse(open(url_dest).read)

    @lat_destination = parsed_data["results"][0]["geometry"]["location"]["lat"]

    @lng_destination = parsed_data["results"][0]["geometry"]["location"]["lng"]
  end
end
