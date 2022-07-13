# frozen_string_literal: true

require './require_app'
require_app

run Tripbook::Api.freeze.app
