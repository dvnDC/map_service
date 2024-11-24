# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      wash_out :map
    end
  end
end
