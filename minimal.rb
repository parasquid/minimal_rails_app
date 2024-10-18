require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails", "~> 8.0.0.beta1", require: "rails/all"
end

class App < Rails::Application
  routes.draw do
    get "/", to: ->(_env) { [200, {}, ["Hello, Rails!"]] }
  end
end

require "rails/command"
require "rails/commands/server/server_command"
Rails.logger = Logger.new($stdout)
Rails::Server.new(app: App, Host: "0.0.0.0", Port: 3000).start
