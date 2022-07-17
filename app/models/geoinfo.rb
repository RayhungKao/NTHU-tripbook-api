# frozen_string_literal: true

require 'json'
require 'sequel'

module Tripbook
  class Geoinfo < Sequel::Model
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :userId, :poiId, :entryOrExit

    # Secure getters and setters
    def poiId
      SecureDB.decrypt(poiId_secure)
    end

    def poiId=(plaintext)
      self.poiId_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'geoInfo',
          attributes: {
            userId:,
            poiId:,
            entryOrExit:
          },
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
