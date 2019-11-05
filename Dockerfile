FROM ruby:2.6.5

ENV APP_HOME=/home/build

# Install tools for debug and development
RUN apt-get update && apt-get install -y git curl wget

WORKDIR $APP_HOME

# Install dependencies defined in Gemfile.
COPY Gemfile Gemfile.lock $APP_HOME/
RUN bundle install --binstubs

ENV PATH=$APP_HOME/bin:$PATH

# Copy application sources.
COPY . $APP_HOME
