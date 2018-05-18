# frozen_string_literal: true

require 'firebase'

module FirebaseClient
  def self.create
    Firebase::Client.new(ENV['FIREBASE_BASE_URI'])
  end
end
