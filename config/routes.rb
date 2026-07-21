# frozen_string_literal: true

Ask::Rails::Engine.routes.draw do
  root to: "chat#index"

  resources :sessions, only: [:index, :create, :show], controller: "chat" do
    collection do
      delete :destroy
    end
  end

  post "sessions/:session_id/messages" => "chat#message", as: :session_message
  get "sessions/:session_id/stream" => "chat#stream", as: :session_stream
  get "sessions/:session_id/messages" => "chat#history", as: :session_history
end
