require 'otw_date'

class Photo < ActiveRecord::Base  
  PHOTO_DISPLAY = 14
  
  def term
    OTWDate.getDates(self.year, self.week)[:term]
  end
  
  def self.search(tag, dates)  
    photo = Photo.where(:year => dates[:year], :week => dates[:week], :tag => tag).first

    if photo.blank?
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
  
  def self.random_tag
    tags = Photo.select('distinct tag')
    tags[rand(tags.size - 1)].tag
  end
  
  def self.recent_photos (user)
    result = []

    if !user.nil?
      photoIds = Activity.viewed_photos_by_user(user, PHOTO_DISPLAY)
      result = photoIds.collect {|id| Photo.find(id) } 
    end
    
    result
  end
  
  def self.popular_photos
    Photo.where(:year => OTWDate.currentYear).where(:week => OTWDate.currentWeek).order("views DESC").limit(PHOTO_DISPLAY)
  end
end
