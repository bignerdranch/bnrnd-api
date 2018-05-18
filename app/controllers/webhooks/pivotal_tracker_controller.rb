# frozen_string_literal: true

require 'firebase_client'

module Webhooks
  class PivotalTrackerController < ApplicationController
    def receive_webhook
      story_update = params['kind'] == 'story_update_activity'

      if story_update
        case params['highlight']
        when 'delivered'
          story_delivered
        when 'accepted', 'rejected'
          story_complete
        end
      end

      head :no_content
    end

    private

    def day_path
      'projectData/sprints/0/days/0'
    end

    def story_count_path
      "#{day_path}/storiesDelivered"
    end

    def firebase
      @firebase ||= FirebaseClient.create
    end

    def story_delivered
      puts 'STORY DELIVERED'

      num_stories = firebase.get(story_count_path).body
      response = firebase.update(day_path, { storiesDelivered: num_stories + 1 })
      puts response.success?
      puts response.body
    end

    def story_complete
      puts 'STORY ACCEPTED OR REJECTED'

      num_stories = firebase.get(story_count_path).body
      response = firebase.update(day_path, { storiesDelivered: num_stories - 1 })
      puts response.success?
      puts response.body
    end
  end
end
