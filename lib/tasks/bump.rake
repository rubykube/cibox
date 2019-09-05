# encoding: UTF-8
# frozen_string_literal: true

require_relative '../bumper'

namespace :release do
  desc 'Tag and push (Drone CI)'
  task :push do
    required_envs = {
      branch:     ENV.fetch('DRONE_BRANCH'),
      repository: ENV.fetch('DRONE_REPO'),
      password:   ENV.fetch('GITHUB_API_KEY')
    }

    envs = {
      name:     ENV.fetch('BOT_NAME', 'Kite Bot'),
      email:    ENV.fetch('BOT_EMAIL', 'kite-bot@heliostech.fr'),
      username: ENV.fetch('BOT_USERNAME', 'kite-bot')
    }

    begin
      bumper = Bumper.new(envs.merge(required_envs))
      bumper.bump
      bumper.tag_n_commit
      bumper.push
      bumper.save
    rescue StandardError => e
      puts "Error: #{e}"
    end
  end
end
