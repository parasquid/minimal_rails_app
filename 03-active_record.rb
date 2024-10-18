# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rails", "~> 8.0.0.beta1", require: "rails/all"
  gem "sqlite3", ">= 2.1"
end

ENV["DATABASE_URL"] = "sqlite3:#{__FILE__}.sqlite3"
ActiveRecord::Base.establish_connection
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.text :body
  end
end

class Post < ActiveRecord::Base; end

class App < Rails::Application
  routes.draw do
    resources :posts
    root to: "posts#index"
  end
end

HTML_TEMPLATE = <<~HTML.strip
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8" />
      <title>App</title>
    </head>
    <body>
      %{body}
    </body>
  </html>
HTML

class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers
end

class PostsController < ApplicationController
  def index
    @posts = Post.all

    template = <<~HTML.strip
      <h1>Posts</h1>
      <ul>
        <% @posts.each do |post| %>
          <li><%= link_to post.title, post_path(post) %></li>
        <% end %>
      </ul>
      <%= link_to "New Post", new_post_path %>
    HTML

    render inline: HTML_TEMPLATE % {body: template}
  end

  def new
    @post = Post.new

    template = <<~HTML.strip
      <h1>New Post</h1>
      <%= form_with model: @post do |form| %>
        <div>
          <%= form.label :title %>
          <%= form.text_field :title %>
        </div>
        <div>
          <%= form.label :body %>
          <%= form.text_area :body %>
        </div>
        <div>
          <%= form.submit %>
        </div>
      <% end %>
    HTML

    render inline: HTML_TEMPLATE % {body: template}
  end

  def create
    post_params = params.require(:post).permit(:title, :body)
    @post = Post.new(post_params)

    @post.save ? redirect_to(posts_path) : render(:new)
  end

  def show
    @post = Post.find(params[:id])

    template = <<~HTML.strip
      <h1><%= @post.title %></h1>
      <p><%= @post.body %></p>
      <%= link_to "Back", posts_path %>
      <%= link_to "Edit", edit_post_path(@post) %>
    HTML

    render inline: HTML_TEMPLATE % {body: template}
  end

  def edit
    @post = Post.find(params[:id])

    template = <<~HTML.strip
      <h1>Edit Post</h1>
      <%= form_with model: @post, url: post_path(@post), method: :patch do |form| %>
        <div>
          <%= form.label :title %>
          <%= form.text_field :title %>
        </div>
        <div>
          <%= form.label :body %>
          <%= form.text_area :body %>
        </div>
        <div>
          <%= form.submit %>
        </div>
      <% end %>
    HTML

    render inline: HTML_TEMPLATE % {body: template}
  end

  def update
    @post = Post.find(params[:id])
    post_params = params.require(:post).permit(:title, :body)

    @post.update(post_params) ? redirect_to(post_path(@post)) : render(:edit)
  end
end

require "rails/command"
require "rails/commands/server/server_command"
Rails.logger = Logger.new($stdout)
Rails::Server.new(app: App, Host: "0.0.0.0", Port: 3000).start
