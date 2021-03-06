# frozen_string_literal: true

module Tripbook
  # Policy to determine if account can view a project
  class EventPolicy
    def initialize(account, event, auth_scope = nil)
      @account = account
      @event = event
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_owns_calendar? || account_involve_in_calendar?)
    end

    def can_edit?
      can_write? && (account_owns_calendar? || account_involve_in_calendar?)
    end

    def can_delete?
      can_write? && (account_owns_calendar? || account_involve_in_calendar?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('events') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('events') : false
    end

    def account_owns_calendar?
      @event.calendar.owner == @account
    end

    def account_involve_in_calendar?
      @event.calendar.members.include?(@account)
    end
  end
end
