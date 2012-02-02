OfTheWeek::Application.routes.draw do
  root :to => 'home#index'
  
  match "/:search_term" => 'photo#search'
  match "/s/:search_term" => 'photo#search'
  match "/s/:search_term/:year/:week" => 'photo#search'
  match "/p/:photo_id" => 'photo#load'
  
end
