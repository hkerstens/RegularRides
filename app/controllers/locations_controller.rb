require 'open-uri'
require 'json'

class LocationsController < ApplicationController
  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
    @location_address = @location.address
    @lat_current = params[:startLat]
    @lng_current = params[:startLng]
    url_safe_street_address = URI.encode(@location_address)

    url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address}"
    open(url)
    raw_data = open(url).read

    parsed_data = JSON.parse(open(url).read)

    @latitute = parsed_data["results"][0]["geometry"]["location"]["lat"]

    @longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]

  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new
    @location.name = params[:name]
    @location.address = params[:address]
    @location.lat = params[:lat]
    @location.lng = params[:lng]
    @location.user_id = params[:user_id]

    if @location.save
      redirect_to "/locations", :notice => "Location created successfully."
    else
      render 'new'
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])

    @location.name = params[:name]
    @location.address = params[:address]
    @location.lat = params[:lat]
    @location.lng = params[:lng]
    @location.user_id = params[:user_id]

    if @location.save
      redirect_to :back, :notice => "Location updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @location = Location.find(params[:id])

    @location.destroy

    redirect_to "/locations", :notice => "Location deleted."
  end
end
