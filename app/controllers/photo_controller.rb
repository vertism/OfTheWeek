require 'flickr_fu'
require 'otw_date'

class PhotoController < ApplicationController
  def load
    id = params[:photo_id]
    @photo = Photo.find_by_id(id)
    
    render :search
  end
  
  def search
    searchterm = params[:search_term]
    year = params[:year] || OTWDate.currentYear
    week = params[:week] || OTWDate.currentWeek
    dates = OTWDate.getDates(year, week)
    
    if !dates.nil?    
      searchterm = searchterm.downcase.gsub(/[^a-z0-9\s]/, '')
      @photo = Photo.search(searchterm, dates)
      
      if !@photo.blank?
        Activity.create(:user => request.session_options[:id], :photo => @photo)
      end
    end
  end
  
end