# Tripbook API

API to store and share a calendar, to facilitate users organise events.

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/events/`: returns all configuration IDs
- GET `api/v1/events/[ID]`: returns details about a single event with given ID
- POST `api/v1/events/`: creates a new event

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```

## Local setup

```shell
cp config/secrets-example.yml config/secrets.yml
rake db:migrate && rake db:seed   # seeds a demo account: demo / tripbook-demo
rake run:dev                      # API on http://localhost:3000
```

## Demo deployment

The API ships with a `Dockerfile` and is deployed together with the web app through the Render Blueprint
(`render.yaml`) in [NTHU-tripbook-app](https://github.com/RayhungKao/NTHU-tripbook-app).
On boot it migrates and seeds a SQLite database (`DATABASE_URL=sqlite://...`); set `DATABASE_URL`
to a PostgreSQL URL instead if demo data should survive restarts.
