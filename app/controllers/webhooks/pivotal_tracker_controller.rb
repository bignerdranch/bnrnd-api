# frozen_string_literal: true

require 'firebase_client'

module Webhooks
  class PivotalTrackerController < ApplicationController
    def receive_webhook
      story_update = params['kind'] == 'story_update_activity'

      if story_update
        case params['highlight']
        when 'accepted', 'rejected'
          story_complete(params['highlight'])
        end
      end

      head :no_content
    end

    private

    def story_events_path
      'projectData/storyEvents'
    end

    def story_event_index_path(index)
      "#{story_events_path}/#{index}"
    end

    def firebase
      @firebase ||= FirebaseClient.create
    end

    def story_complete(type)
      puts 'STORY ACCEPTED OR REJECTED'

      story_events = firebase.get(story_events_path)
      new_index = story_events.body.count

      story_event_data = {
        date: DateTime.now.strftime('%Y-%m-%d'),
        type: type,
      }
      response = firebase.set(story_event_index_path(new_index), story_event_data)
      puts response.success?
      puts response.body
    end
  end
end
