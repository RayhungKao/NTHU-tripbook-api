# frozen_string_literal: true

require 'roda'
require_relative './app'

module Tripbook
  # Web controller for Tripbook API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('maps') do |routing|
      @map_route = "#{@api_root}/maps"

      routing.on String do |map_id|
        routing.on 'pois' do
					@poi_route = "#{@api_root}/maps/#{map_id}/pois"
					# GET api/v1/maps/[map_id]/pois/[poi_id]
					routing.get String do |poi_id|
						poi = Poi.where(map_id: map_id, id: poi_id).first
						poi ? poi.to_json : raise('Poi not found')
					rescue StandardError => e
						routing.halt 404, { message: e.message }.to_json
					end

					# GET api/v1/maps/[map_id]/pois
					routing.get do
						output = { data: Map.first(id: map_id).pois }
						JSON.pretty_generate(output)
					rescue StandardError
						routing.halt(404, { message: 'Could not find pois' }.to_json)
					end

					# POST api/v1/maps/[map_id]/pois
					routing.post do
						new_data = JSON.parse(routing.body.read)

						new_poi = Map.first(id: map_id).add_poi(new_data)

						response.status = 201
						response['Location'] = "#{@poi_route}/#{new_poi.id}"
						{ message: 'Poi saved', data: new_poi }.to_json
					rescue Sequel::MassAssignmentRestriction
						Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
						routing.halt 400, { message: 'Illegal Attributes' }.to_json
					rescue StandardError => e
						Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
						routing.halt 500, { message: 'Error creating poi' }.to_json
					end
        end
        
        # GET api/v1/maps/[map_id]
        routing.get do
          map = Map.first(id: map_id)
          map ? map.to_json : raise('Map not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/maps
      routing.get do
        output = { data: Map.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find map' }.to_json
      end

      # POST api/v1/maps
      routing.post do
        new_data = JSON.parse(routing.body.read)
        puts new_data
        new_map = Map.new(new_data)
        raise('Could not save map') unless new_map.save

        response.status = 201
        { message: 'Map saved', data: new_map }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
