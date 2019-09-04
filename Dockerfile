FROM ruby:2.6.3

ENV APP_HOME=/home/build

# Install tools for debug and development
RUN apt-get update && apt-get install -yy \
        git curl wget

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY Gemfile Gemfile.lock $APP_HOME/
RUN mkdir -p /opt/vendor/bundle \
 && bundle install --path /opt/vendor/bundle

# Copy application sources.
COPY . $APP_HOME
