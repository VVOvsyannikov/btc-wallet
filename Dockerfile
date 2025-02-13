FROM ruby:3.0.1-alpine

RUN apk add --no-cache build-base git bash

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

ENV BUNDLE_PATH=/usr/local/bundle

COPY . .