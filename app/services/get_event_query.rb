# frozen_string_literal: true

module Tripbook
  # Service object to create a new group for an owner
  class GetEventQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that event'
      end
    end

    # Error for cannot find a calendar
    class NotFoundError < StandardError
      def message
        'We could not find that event'
      end
    end

    def self.call(auth:, event:)
      raise NotFoundError unless event

      policy = EventPolicy.new(auth[:account], event, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      event
    end
  end
end
