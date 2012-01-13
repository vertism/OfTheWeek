require 'flickr_fu'

class HomeController < ApplicationController
  def index
  end
  
  def search
    searchterm = params[:search_term]
    year = params[:year] || Time.now.to_date.cwyear
    week = params[:week] || Time.now.to_date.cweek
    
    searchterm = searchterm.downcase.gsub(/[^a-z0-9]/, '')

    @title = searchterm + " of the week"
    @imageURL = nil
    
    photo = getimageurl(searchterm, year, week)
    if !photo.blank?
      @imageURL = photo.url
    end
  end
  
  def getimageurl(tag, year, week)
    dates = getDates(year, week)
  
    photo = Photo.where(:year => year, :week => week, :tag => tag).first
    
    if photo.blank? and !dates.nil?
    
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
          photo = Photo.create!(:year => year, :week => week, :tag => tag, :url => photos.first.url)
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
    
      {:min => minDate.strftime('%s'), :max => maxDate.strftime('%s')}
    rescue
      nil
    end
  end
  
end
