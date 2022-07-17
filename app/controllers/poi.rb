# frozen_string_literal: true

require 'roda'
require_relative './app'

module Tripbook
  # Web controller for Tripbook API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('pois') do |routing|
      @poi_route = "#{@api_root}/pois"

      # GET api/v1/pois
      routing.get do
        output = { data: Poi.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find poi' }.to_json
      end

      # # POST api/v1/pois
      # routing.post do
      #   new_data = JSON.parse(routing.body.read)
      #   puts new_data
      #   new_poi = Poi.new(new_data)
      #   raise('Could not save poi') unless new_poi.save

      #   response.status = 201
      #   { message: 'PoI saved', data: new_poi }.to_json
      # rescue Sequel::MassAssignmentRestriction
      #   Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
      #   routing.halt 400, { message: 'Illegal Attributes' }.to_json
      # rescue StandardError => e
      #   Api.logger.error "UNKOWN ERROR: #{e.message}"
      #   routing.halt 500, { message: 'Unknown server error' }.to_json
      # end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
