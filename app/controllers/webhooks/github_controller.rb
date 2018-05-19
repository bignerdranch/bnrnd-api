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

    def prs_path
      'projectData/pullRequests'
    end

    def pr_index_path(index)
      "#{prs_path}/#{index}"
    end

    def firebase
      @firebase ||= FirebaseClient.create
    end

    def commits_merged(num_commits)
      puts 'PR MERGED'

      prs = firebase.get(prs_path)
      new_index = prs.body.count

      pr_data = {
        date: DateTime.now.strftime('%Y-%m-%d'),
        commits: num_commits,
      }
      response = firebase.set(pr_index_path(new_index), pr_data)
      puts response.success?
      puts response.body
    end
  end
end
