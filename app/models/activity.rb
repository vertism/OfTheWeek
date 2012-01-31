class Activity < ActiveRecord::Base
  belongs_to :photo
  
  def self.viewed_photos_by_user(user, count)
    photoIDs = Activity.where(:user => user).select("photo_id, created_at").order("created_at DESC")
    
    #get array of unique photos
    photos = photoIDs.inject({}) do |hash, item|
       hash[item.photo_id] ||= item.photo_id
       hash 
    end.values
    
    photos.slice!(0,count)
  end
end
