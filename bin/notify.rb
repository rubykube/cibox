#!/usr/bin/env ruby
# Usage: /bin/bump --branch=customer/name

require 'git'
require 'telegram/bot'

class Notify
  def initialize(params)
    @telegram_token = params[:telegram_token]
    @telegram_chat_id = params[:telegram_chat_id]
    @repository = params[:repository]

    @git = Git.open(Dir.getwd)
  end

  def notify(network)
    case network
    when 'telegram'
      notify_by_telegram
    else
      raise 'Available option for social networks: telegram'
    end
  end

  def notify_by_telegram
    Telegram::Bot::Client.run(@telegram_token) do |bot|
      bot.api.send_message(
        chat_id: @telegram_chat_id,
        text: "New patch for [#{repo_name}](https://gihub.com/#{@repository}) has been merged.
Latest changes are:
#{@git.log.first.message}.
You can find out more at [here](https://github.com/ruby-git/#{@repository}/commit/#{@git.log.first.sha})",
        parse_mode: 'Markdown')
    end
  end

  private

  def repo_name
    @repository.split('/').last
  end
end

params = {
  telegram_token: ENV.fetch('TELEGRAM_TOKEN', ''),
  telegram_chat_id: ENV.fetch('TELEGRAM_CHAT_ID', ''),
  repository: ENV.fetch('DRONE_REPO')
}

begin
  notifier = Notify.new(params)
  notifier.notify(ARGV[0])
rescue StandardError => e
  puts "Error: #{e}"
end
