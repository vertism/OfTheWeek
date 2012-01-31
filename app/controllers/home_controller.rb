require 'flickr_fu'

class HomeController < ApplicationController
  include HomeHelper
  
  def index
    if params[:commit] == 'Random'
      redirect_to '/' + Photo.random_tag
    elsif !params[:search_term].nil?
      redirect_to '/' + params[:search_term]
    end
    
    @recent = []
    recent_photo_total = 14
    if !request.session_options[:id].nil?
      photoIds = Activity.viewed_photos_by_user(request.session_options[:id], recent_photo_total)
      @recent = photoIds.collect {|id| Photo.find(id) } 
    end
        
    @popular = Photo.where(:year => getYear).where(:week => getWeek).order("views DESC").limit(recent_photo_total)
  end
  
  def load
    id = params[:photo_id]
    show_photo(Photo.find_by_id(id))
  end
  
  def search
    searchterm = params[:search_term]
    year = params[:year] || getYear
    week = params[:week] || getWeek
    dates = getDates(year, week)
    
    if !dates.nil?    
      searchterm = searchterm.downcase.gsub(/[^a-z0-9\s]/, '')
      show_photo(get_photo(searchterm, dates))
    end
  end
  
  def show_photo(photo)
    if !photo.blank?
      Activity.create(:user => request.session_options[:id], :photo => photo)
      
      @title = photo.tag + ' of the week'
      @term = getDates(photo.year, photo.week)[:term]
      @imageURL_medium = photo.url_square
      @imageURL_large = photo.url_original
      @views = photo.views
      @lastweekURL = getURL(photo, -1) 
      @nextweekURL = getURL(photo, 1)
    end
    
    render :search
  end
  
  def get_photo(tag, dates)  
    photo = Photo.where(:year => dates[:year], :week => dates[:week], :tag => tag).first
    
    if photo.blank?
    
      #TODO: check out flickraw as an alternative
      begin
        file = Rails.root.join('config','flickr.yml').to_s
        flickr = Flickr.new(:key => ENV['FLICKR_KEY'], :secret => ENV['FLICKR_SECRET'])
          
        photos = flickr.photos.search(
          :tags => tag,
          :tag_mode => 'all',
          :sort => 'interestingness-desc',
          :content_type => 1,
          :min_upload_date => dates[:min], :max_upload_date => dates[:max],
          :per_page => 1
        )
      rescue
      end
    
      unless photos.nil?
        begin
          large = photos.first.url(:original) || photos.first.url(:large)
          photo = Photo.create!(
            :year => dates[:year], 
            :week => dates[:week], 
            :tag => tag, 
            :url_square => photos.first.url(:medium), 
            :url_thumbnail => photos.first.url(:thumbnail), 
            :url_original => large,
            :views => 1
          )
          photo.save
        rescue
        end
      end
    else
      photo.views += 1
      photo.save
    end
    
    photo
  end
  
end