OfTheWeek::Application.routes.draw do
  root :to => 'home#index'
  
  match "/:search_term" => 'home#search'
  match "/:search_term/:year/:week" => 'home#search'
end
