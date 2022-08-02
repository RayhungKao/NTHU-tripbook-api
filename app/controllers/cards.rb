# frozen_string_literal: true

require 'roda'
require_relative './app'

module Tripbook
  # Web controller for Tripbook API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('cards') do |routing|
      @card_route = "#{@api_root}/cards"
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account
      @account = @auth_account

      routing.on String do |username|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/cards/[username]
        routing.get do
          account = Account.first(username:username)
          output = { data: account.owned_cards }
          JSON.pretty_generate(output)
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET CARD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

        # POST api/v1/cards/[username]
        routing.post do
          new_data = JSON.parse(routing.body.read)
          account = Account.first(username:username)
          new_card = account.add_owned_card(new_data)

          raise('Could not save card') unless new_card.save
          
          response.status = 201
          { message: 'Card saved', data: new_card }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end

      # POST api/v1/cards
      routing.post do
        new_data = JSON.parse(routing.body.read)
        puts new_data
        new_card = Card.create(new_data)
        raise('Could not save card') unless new_card.save

        response.status = 201
        { message: 'Card saved', data: new_card }.to_json
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
