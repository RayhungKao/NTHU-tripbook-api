# frozen_string_literal: true

require 'json'
require 'sequel'

module Tripbook
  # Holds a full secret receipt
  class Card < Sequel::Model
    many_to_one :owner, class: :'Tripbook::Account'

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :card_code

    def to_h
      {
        data: {
          type: 'card',
          attributes: {
            id:,
            card_code:
          }
        }
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
