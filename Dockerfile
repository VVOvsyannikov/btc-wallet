FROM ruby:3.2-alpine

RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.16/main" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache build-base git bash libssl1.1

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

ENV BUNDLE_PATH=/usr/local/bundle

COPY . .