require 'flickr_fu'

class HomeController < ApplicationController
  def index
  end
  
  def search
    @imageURL = getimage(params[:search_term]).url
  end
  
  def getimage(search)
    file = Rails.root.join('config','flickr.yml').to_s
    flickr = Flickr.new(file)
    
    tags = search.split("+").join(",")
    
    photos = flickr.photos.search(:tags => tags, :min_upload_date =>'2012-01-09', :max_upload_date => '2012-01-14')
    
    photos[0]
  end

end
