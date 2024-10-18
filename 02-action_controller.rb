# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails", "~> 8.0.0.beta1", require: "rails/all"
end

class App < Rails::Application
  routes.draw do
    get "/" => "home#index"
  end
end

class HomeController < ActionController::Base
  def index
    render inline: <<~HTML.strip
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <title>App</title>
        </head>
        <body>
          <h1>Hello, Rails!</h1>
          <p>Lorem ipsum et cetera.</p>
        </body>
      </html>
    HTML
  end
end

require "rails/command"
require "rails/commands/server/server_command"
Rails.logger = Logger.new($stdout)
Rails::Server.new(app: App, Host: "0.0.0.0", Port: 3000).start
