# frozen_string_literal: true

require 'json'
require 'sequel'

module Tripbook
  class Map < Sequel::Model
    one_to_many :pois

    plugin :association_dependencies,
            pois: :destroy

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'map',
          attributes: {
            id:,
            name:,
            pois:
          },
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
