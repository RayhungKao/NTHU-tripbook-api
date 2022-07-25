# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:geoinfos) do
      primary_key :id

      String :username
      String :poiId
      Boolean :entered
      String :entryTime

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
