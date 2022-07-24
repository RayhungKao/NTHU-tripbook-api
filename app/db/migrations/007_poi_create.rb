# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:pois) do
      primary_key :id
      foreign_key :map_id, table: :maps

      String :name, unique:true
      String :latitude_secure, null: false
      String :longitude_secure, null: false
      String :radius

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
