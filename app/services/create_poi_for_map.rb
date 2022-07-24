# frozen_string_literal: true

module Tripbook
  # Service object to create a new poi for a map
  class CreatePoiforMap
    def self.call(map_name:, poi_data:)
      map = Map.first(name: map_name)
      raise('Could not save poi') unless map.add_poi(poi_data)

      Poi.first(name: poi_data['name'])
    end
  end
end
