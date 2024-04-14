Rails.application.routes.draw do
  get 'groups/new'
  get 'groups/edit'
  get 'groups/show'
  get 'groups/index'
  root to: 'homes#top'
  get 'home/about' => 'homes#about',as: 'about'

  devise_for :users

  devise_scope :user do
    post 'users/guest_sign_in', to: "users/sessions#guest_sign_in", as: 'guest_sign_in'
  end

  resources :users, only: [:show, :index, :edit, :update] do
    get 'search_count'
    resource :relationships, only: [:create, :destroy] do
      get 'followings' => 'relationships#followings', as: "followings"
      get 'followers' => 'relationships#followers', as: "followers"
    end
  end

  resources :groups do
    resource :group_users, only: [:create, :destroy], as: "user"
  end

  resources :books, only: [:show, :index, :create, :edit, :update, :destroy] do
    resource :favorites, only: [:create, :destroy]
    resources :book_comments, only: [:create, :destroy]
  end

  resources :rooms, only: [:create, :show]
  resources :messages, only: [:create]

  get 'search' => 'searches#search'
end