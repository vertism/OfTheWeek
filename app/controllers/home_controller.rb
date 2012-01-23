require 'flickr_fu'

class HomeController < ApplicationController
  include HomeHelper
  
  def index
    if params[:commit] == 'Random'
      tags = Photo.select('distinct tag')
      tag = tags[rand(tags.size - 1)].tag
      redirect_to '/' + tag
    elsif !params[:search_term].nil?
      redirect_to '/' + params[:search_term]
    end
    
    @recent = []
    if !request.session_options[:id].nil?
      photoIDs = Activity.where(:user => request.session_options[:id]).select("photo_id, created_at")
      photoIDs.sort_by!{|x| [ ItemForReverseSort.new(x.created_at) ]}
      photos = photoIDs.inject({}) do |hash,item|
         hash[item.photo_id]||=item.photo_id
         hash 
      end.values
    
      photos.each_with_index do |id, index|
        break if index >= 14
        @recent.push(Photo.find(id))
      end
    end
        
    @popular = Photo.where(:year => getYear).where(:week => getWeek).order("views DESC").limit(14)
  end
  
  def search
    searchterm = params[:search_term]
    year = params[:year] || getYear
    week = params[:week] || getWeek
    dates = getDates(year, week)
    
    if !dates.nil?    
      searchterm = searchterm.downcase.gsub(/[^a-z0-9]/, '')

      @title = searchterm + " of the week"
      @imageURL = nil
      @term = dates[:term]
    
      photo = getimageurl(searchterm, dates)
      
      if !photo.blank?
        Activity.create(:user => request.session_options[:id], :photo => photo)
        
        @imageURL_medium = photo.url_square
        @imageURL_large = photo.url_original
        @views = photo.views
        @lastweekURL = getURL(searchterm, year, week, -1) 
        @nextweekURL = getURL(searchterm, year, week, 1)
      end
    end
  end
  
  def getimageurl(tag, dates)  
    photo = Photo.where(:year => dates[:year], :week => dates[:week], :tag => tag).first
    
    if photo.blank?
    
      #TODD: check out flickraw as an alternative
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

class ItemForReverseSort
  def initialize( item )
    @item = item
  end
  def item
    @item
  end
  def <=>( target )
    ( self.item <=> target.item ) * (-1)
  end
end
