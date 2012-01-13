require 'flickr_fu'

class HomeController < ApplicationController
  def index
  end
  
  def search
    searchterms = params[:search_term]
    @title = searchterms.split("+").join(" ") + " of the week"
    @imageURL = getimageurl(searchterms)
    if @imageURL.nil?
      render :inline =>
        "Sorry, there are no results for your search"
    end
  end
  
  def getimageurl(search)
    file = Rails.root.join('config','flickr.yml').to_s
    flickr = Flickr.new(file)
    
    tags = search.split("+").join(",")
    
    photos = flickr.photos.search(
      :tags => tags,
      :tag_mode => 'all',
      :sort => 'interestingness-desc',
      :content_type => 1,
      :min_upload_date => getDate(1), :max_upload_date => getDate(2),
      :per_page => 1
    )
    
    if photos.first.nil?
      nil
    else
      photos.first.url
    end
  end
  
  def getDate(type)
    now = Time.now.to_date
    minDate = now - 7 - now.cwday + 1
    maxDate = minDate + 7
    
    case type
    when 1 #min
      minDate.strftime('%s')
    when 2 #max
      maxDate.strftime('%s')
    else
      nil
    end
  end
  
end
