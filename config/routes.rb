Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  root to: 'dashboard#index'
  get 'lockbox_partners', to: 'dashboard#index'

  get 'onboarding_success', to: 'dashboard#onboarding_success'

  match 'support_requests/new', to: 'lockbox_partners/support_requests#new', via: [:get]
  resources :support_requests, only: [:index, :create]

  resources :lockbox_partners, only: [:new, :create, :show, :edit, :update] do
    scope module: 'lockbox_partners' do
      resources :users, only: [:new, :create]
      resources :support_requests, except: [:index, :destroy] do
        post 'update_status', to: 'support_requests#update_status', as: 'update_status'
        resources :notes, only: [:create, :show, :edit, :update]
      end
      resource :add_cash, only: [:new, :create], controller: 'add_cash'
      resource :reconciliation, only: [:new, :create], controller: 'reconciliation'
    end
  end

  resources :lockbox_actions, only: [:update]
end
