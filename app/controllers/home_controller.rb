class HomeController < ApplicationController
  def index
    if params[:commit] == 'Random'
      redirect_to '/s/' + Photo.random_tag
    elsif !params[:search_term].nil?
      redirect_to '/s/' + params[:search_term]
    end
    
    @recent = Photo.recent_photos(request.session_options[:id])
    @popular = Photo.popular_photos
  end
end