Rails.application.routes.draw do
  mount Fuik::Engine => "/webhooks"
end
