class Photo < ActiveRecord::Base
  
  def self.random_tag
    tags = Photo.select('distinct tag')
    tags[rand(tags.size - 1)].tag
  end
end
