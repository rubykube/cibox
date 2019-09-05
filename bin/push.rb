#!/usr/bin/env ruby
# Usage: /bin/bump --branch=customer/name

require 'bump'
require 'git'
require 'logger'

class Bumper
  CUSTOMER_PREFIX = 'customer/'.freeze

  def initialize(params)
    @semver   = params[:semver]
    @username = params[:username]
    @password = params[:password]
    @branch   = params[:branch]
    @repository = params[:repository]

    @git = Git.open(Dir.getwd)

    @git.config('user.name', params[:name])
    @git.config('user.email', params[:email])
  end

  def bump
    Bump::Bump.run(@semver, commit: false, bundle: false, tag: false)
    @tag = Bump::Bump.current
  end

  def commit
    if master?
      @git.commit_all("[ci skip] Release new version #{@tag}")
      @git.add_tag("v#{@tag}", message: "Release new version #{@tag}")
    elsif customer?
      @git.commit_all("[ci skip] Release new version #{customer}-v#{@tag}")
      @git.add_tag("#{customer}-v#{@tag}", message: "Release #{customer}-v#{@tag}")
    else
      raise "unexprected branch #{@branch}. skipped!"
    end
  end

  def push
    @remote ||= @git.add_remote('authenticated-origin', "https://#{@username}:#{@password}@github.com/#{@repository}", fetch: true)
    @git.push(@remote, @branch, true)
  end


  def save
    File.open('.tags', 'w') {|f| f.write(@tag) }
  end

  private

  def customer?
    @branch.start_with?(CUSTOMER_PREFIX)
  end

  def customer
    @branch.gsub(CUSTOMER_PREFIX, '')
  end

  def master?
    @branch == 'master'
  end
end

params = {
  semver: 'patch',
  branch: ENV.fetch('DRONE_BRANCH'),
  name: ENV.fetch('BOT_NAME', 'Kite Bot'),
  email: ENV.fetch('BOT_EMAIL', 'kite-bot@heliostech.fr'),
  username: ENV.fetch('BOT_USERNAME', 'kite-bot'),
  password: ENV.fetch('GITHUB_API_KEY'),
  repository: ENV.fetch('DRONE_REPO')
}

begin
  bumper = Bumper.new(params)
  bumper.bump
  bumper.commit
  bumper.push
  bumper.save
rescue StandardError => e
  puts "Error: #{e}"
end
