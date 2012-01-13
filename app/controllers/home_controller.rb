require 'flickr_fu'

class HomeController < ApplicationController
  def index
  end
  
  def search
    searchterm = params[:search_term]
    year = params[:year] || Time.now.to_date.cwyear
    week = params[:week] || Time.now.to_date.cweek
    dates = getDates(year, week)
    
    if !dates.nil?    
      searchterm = searchterm.downcase.gsub(/[^a-z0-9]/, '')

      @title = searchterm + " of the week"
      @imageURL = nil
      @term = dates[:term]
    
      photo = getimageurl(searchterm, dates)
      
      if !photo.blank?
        @imageURL = photo.url
      end
    end
  end
  
  def getimageurl(tag, dates)  
    photo = Photo.where(:year => dates[:year], :week => dates[:week], :tag => tag).first
    
    if photo.blank?
    
      file = Rails.root.join('config','flickr.yml').to_s
      flickr = Flickr.new(file)
          
      photos = flickr.photos.search(
        :tags => tag,
        :tag_mode => 'all',
        :sort => 'interestingness-desc',
        :content_type => 1,
        :min_upload_date => dates[:min], :max_upload_date => dates[:max],
        :per_page => 1
      )
      
      photo = photos.first
    
      unless photos.first.nil?
        begin
          photo = Photo.create!(:year => dates[:year], :week => dates[:week], :tag => tag, :url => photos.first.url)
          photo.save
        rescue
        end
      end
    end
    
    photo
  end
  
  def getDates(year, week)
    begin 
      year = year.to_i
      week = week.to_i
      
      minDate = Date.commercial(year, week, 1) - 7
      maxDate = Date.commercial(year, week, 1)
      
      if Time.now.to_date.cwyear == year && Time.now.to_date.cweek == week
        term = ""
      else
        term = maxDate.strftime('%d %b %Y')
      end
    
      {:week => week, :year => year, :min => minDate.strftime('%s'), :max => maxDate.strftime('%s'), :term => term}
    rescue
      nil
    end
  end
  
end
