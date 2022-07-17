# frozen_string_literal: true

require 'roda'
require_relative './app'

module Tripbook
  # Web controller for Tripbook API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('geoinfos') do |routing|
      @geoinfo_route = "#{@api_root}/geoinfos"

      # GET api/v1/geoinfos
      routing.get do
        output = { data: Geoinfo.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find geoinfos' }.to_json
      end

      # POST api/v1/geoinfos
      routing.post do
        new_data = JSON.parse(routing.body.read)
        puts new_data
        new_geoinfo = Geoinfo.new(new_data)
        raise('Could not save geoinfo') unless new_geoinfo.save

        response.status = 201
        { message: 'Geoinfo saved', data: new_geoinfo }.to_json
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
