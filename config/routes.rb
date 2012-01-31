OfTheWeek::Application.routes.draw do
  root :to => 'home#index'
  
  match "/p/:photo_id" => 'home#load'
  match "/:search_term" => 'home#search'
  match "/:search_term/:year/:week" => 'home#search'
end
