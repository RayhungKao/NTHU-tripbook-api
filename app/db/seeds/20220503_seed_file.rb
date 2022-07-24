# frozen_string_literal: true

require './app/controllers/helpers'
include Tripbook::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, documents'
    create_accounts
    create_owned_calendars
    create_calendar_members
    create_events
    create_maps
    create_pois
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
CAL_MEMBER_INFO = YAML.load_file("#{DIR}/calendars_members.yml")
CAL_INFO = YAML.load_file("#{DIR}/calendars_seed.yml")
EVENT_INFO = YAML.load_file("#{DIR}/events_seed.yml")
OWNED_CAL_INFO = YAML.load_file("#{DIR}/owned_calendars.yml")

MAPS_INFO = YAML.load_file("#{DIR}/maps_seed.yml")
POIS_INFO = YAML.load_file("#{DIR}/pois_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Tripbook::Account.create(account_info)
  end
end

def create_owned_calendars
  OWNED_CAL_INFO.each do |owner|
    owner['cal_name'].each do |cal_name|
      cal_data = CAL_INFO.find { |cal| cal['title'] == cal_name }
      Tripbook::CreateCalendarForOwner.call(
        username: owner['username'], calendar_data: cal_data
      )
    end
  end
end

def create_calendar_members
  CAL_MEMBER_INFO.each do |calendar_info|
    calendar = Tripbook::Calendar.first(title: calendar_info['cal_title'])
    calendar_info['member_email'].each do |member|
      auth_token = AuthToken.create(calendar.owner)
      auth = scoped_auth(auth_token)
      Tripbook::AddMemberToCalendar.call(
        auth:, email: member, calendar:
      )
    end
  end
end

def create_events
  event_info_each = EVENT_INFO.each
  calendars_cycle = Tripbook::Calendar.all.cycle
  loop do
    event_info = event_info_each.next
    calendar = calendars_cycle.next

    auth_token = AuthToken.create(calendar.owner)
    auth = scoped_auth(auth_token)

    Tripbook::CreateEventForCalendar.call(
      auth:, cal_id: calendar.id, event_data: event_info
    )
  end
end

def create_maps
  MAPS_INFO.each do |map_info|
    Tripbook::Map.create(map_info)
  end
end

def create_pois
  POIS_INFO.each do |map|
    map_name = map['map_name']
    map_info = map['map_info']
    map_info.each do |poi|
      Tripbook::CreatePoiforMap.call(
        map_name: map_name, poi_data: poi
      )
    end
  end
end