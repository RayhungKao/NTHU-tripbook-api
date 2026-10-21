FROM ruby:3.1.1-slim-bullseye

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential libsodium23 libsqlite3-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV RACK_ENV=production BUNDLE_WITHOUT=development:test

COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install

COPY . .
RUN mkdir -p app/db/store

# Migrate and seed on every boot: with SQLite on an ephemeral disk the demo data resets on each restart
CMD bundle exec rake db:migrate && bundle exec rake db:pdseed && bundle exec puma -t 5:5 -p ${PORT:-9292} -e production
