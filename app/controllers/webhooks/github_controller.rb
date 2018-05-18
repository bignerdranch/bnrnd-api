# frozen_string_literal: true

module Webhooks
  class GithubController < ApplicationController
    CLIENT_ID = ENV['GITHUB_CLIENT_ID']
    CLIENT_SECRET = ENV['GITHUB_CLIENT_SECRET']

    def receive_webhook
      pr_closed = params['pull_request']['state'] == 'closed'

      if pr_closed
        commits_url = params['pull_request']['_links']['commits']['href']
        authd_commits_url = "#{commits_url}?client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}"

        response = HTTParty.get(authd_commits_url)
        num_commits = JSON.parse(response.body).count
        puts "PR CLOSED WITH #{num_commits} commits"
      end

      head :no_content
    end
  end
end
