# frozen_string_literal: true

module Webhooks
  class PivotalTrackerController < ApplicationController
    def receive_webhook
      story_update = params['kind'] == 'story_update_activity'

      if story_update
        case params['highlight']
        when 'delivered'
          story_delivered
        when 'accepted'
          story_accepted
        end
      end

      head :no_content
    end

    private

    def story_delivered
      puts 'STORY DELIVERED'
    end

    def story_accepted
      puts 'STORY ACCEPTED'
    end
  end
end
