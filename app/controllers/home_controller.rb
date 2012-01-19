require 'flickr_fu'

class HomeController < ApplicationController
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
        
    @popular = Photo.where(:year => 2012).where(:week => 3).order("views DESC").limit(14)
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
  
  def getURL(tag, currentYear, currentWeek, offset) 
    newDate = Date.commercial(currentYear.to_i, currentWeek.to_i) + (offset * 7)
    newWeek = newDate.cweek
    newYear = newDate.cwyear
    
    actualYear = Time.now.to_date.cwyear
    actualWeek = Time.now.to_date.cweek
    
    if newYear > actualYear || (newYear == actualYear && newWeek > actualWeek)
      return nil
    end
    
    '/' + tag + '/' + newYear.to_s + '/' + newWeek.to_s
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
