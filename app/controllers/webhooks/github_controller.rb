# frozen_string_literal: true

require 'firebase_client'

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
        commits_merged(num_commits)
      end

      head :no_content
    end

    private

    def day_path
      'projectData/sprints/0/days/0'
    end

    def commits_path
      "#{day_path}/commits"
    end

    def firebase
      @firebase ||= FirebaseClient.create
    end

    def commits_merged(num_merged_commits)
      puts 'PR MERGED'

      num_day_commits = firebase.get(commits_path).body
      response = firebase.update(day_path, { commits: num_day_commits + num_merged_commits })
      puts response.success?
      puts response.body
    end
  end
end
