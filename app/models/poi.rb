# frozen_string_literal: true

require 'json'
require 'sequel'

module Tripbook
  class Poi < Sequel::Model
    many_to_one :map

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :latitude, :longitude, :radius

    # Secure getters and setters
    def latitude
      SecureDB.decrypt(latitude_secure)
    end

    def latitude=(plaintext)
      self.latitude_secure = SecureDB.encrypt(plaintext)
    end

    def longitude
      SecureDB.decrypt(longitude_secure)
    end
  
    def longitude=(plaintext)
      self.longitude_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'poi',
          attributes: {
            id:,
            name:,
            latitude:,
            longitude:,
            radius:,
          },
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
