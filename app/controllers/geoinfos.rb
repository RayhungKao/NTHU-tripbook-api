# frozen_string_literal: true

require 'roda'
require_relative './app'

module Tripbook
  # Web controller for Tripbook API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('geoinfos') do |routing|
      @geoinfo_route = "#{@api_root}/geoinfos"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account
      @account = @auth_account

      # GET api/v1/geoinfos
      routing.get do
        output = { data: Geoinfo.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find geoinfos' }.to_json
      end

      routing.on String do |username|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/geoinfos/[username]
        routing.get do
          output = { data: Geoinfo.where_all(username: @auth_account.username) }
          JSON.pretty_generate(output)
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET GEOINFO ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

        # POST api/v1/geoinfos/[username]
        routing.post do
          new_data = JSON.parse(routing.body.read)
          if ((Geoinfo.first("username": new_data['username']) && Geoinfo.first("poiId": new_data['poiId']) && Geoinfo.first("entered": new_data['entered'])).nil?)
            new_geoinfo = Geoinfo.create(new_data)
            raise('Could not save geoinfo') unless new_geoinfo.save
            response.status = 201
            { message: 'Geoinfo saved', data: new_geoinfo }.to_json
          else 
            response.status = 200
            { message: 'Geoinfo already saved before', data: 'none' }.to_json
          end
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end

      # POST api/v1/geoinfos
      routing.post do
        new_data = JSON.parse(routing.body.read)
        puts new_data
        new_geoinfo = Geoinfo.create(new_data)
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
