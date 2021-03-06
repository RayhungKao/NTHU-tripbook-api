# frozen_string_literal: true

module Tripbook
  # Service object to create a new group for an owner
  class GetCalendarQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that calendar'
      end
    end

    # Error for cannot find a calendar
    class NotFoundError < StandardError
      def message
        'We could not find that calendar'
      end
    end

    def self.call(auth:, calendar:)
      raise NotFoundError unless calendar

      policy = CalendarPolicy.new(auth[:account], calendar, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      return calendar.full_details.merge(policies: policy.summary) if policy.can_edit?
      return calendar.full_events.merge(policies: {}) if policy.can_view?
    end
  end
end
