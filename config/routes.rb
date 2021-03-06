# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :webhooks do
    post 'github', to: 'github#receive_webhook'
    post 'pivotal-tracker', to: 'pivotal_tracker#receive_webhook'
  end
end
