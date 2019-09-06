# encoding: UTF-8
# frozen_string_literal: true

require 'bump'
require 'git'
require 'logger'

class Bumper
  CUSTOMER_PREFIX = 'customer/'

  attr_accessor :username, :branch, :repository
  attr_writer :password
  attr_reader :git

  def initialize(**params)
    @username   = params[:username]
    @password   = params[:password]
    @branch     = params[:branch]
    @repository = params[:repository]

    @git = Git.open(Dir.getwd)
    @git.config('user.name', params[:name])
    @git.config('user.email', params[:email])
  end

  def bump(level: 'patch', commit: false, bundle: false, tag: false)
    Bump::Bump.run(level, commit: commit, bundle: bundle, tag: tag)
  end

  def tag_n_commit(text: 'Release new version')
    raise "Unexprected branch #{@branch}" if tag.nil?

    @git.add_tag(tag, message: "#{text} #{version}")
    @git.commit_all("[ci skip] #{text} #{version}")
  end

  def push
    unless @git.remotes.map(&:name).include?('authenticated-origin')
      @git.add_remote(
        'authenticated-origin',
        "https://#{@username}:#{@password}@github.com/#{@repository}",
        fetch: true
      )
    end

    @git.push(@git.remote('authenticated-origin'), @branch, true)
  end

  def save
    File.open('.tags', 'w') { |f| f.write(version) }
  end

  def version
    Bump::Bump.current
  end

  def tag
    if master?
      "v#{version}"
    elsif customer?
      "#{customer}-v#{version}"
    end
  end

  private

  def customer
    @branch.gsub(CUSTOMER_PREFIX, '')
  end

  def customer?
    @branch.start_with?(CUSTOMER_PREFIX)
  end

  def master?
    @branch == 'master'
  end
end
