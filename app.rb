require 'sinatra'
require 'pry'
require 'yajl'

helpers do
  def request_body
    @request_body ||= Yajl::Parser.parse( request.body )
  end

  def require_params(required_params)
    if request_body.nil?
      return { error: "Post body is not valid JSON" }
    end

    missing_attrs = required_params - request_body.keys
    if missing_attrs.any?
      { error: "Required params missing: #{ missing_attrs.join(', ') }" }
    else
      {}
    end
  end

  def require_auth_header
    if env['HTTP_X_USER_TOKEN']
      {}
    else
      { error: "HTTP header X-User-Token is required" }
    end
  end

  def as_json(obj)
    Yajl::Encoder.encode(obj)
  end
end

get '/' do
  'Have a look at app.rb'
end


# User #create
post '/users' do
  content_type :json

  errors = require_params( %w(handle) )
  status 400 and return( as_json(errors) ) if errors.any?

  status 201
  File.read("fixtures/create_user.json")
end


# Post #create
post '/posts' do
  content_type :json

  errors = require_auth_header
  status 401 and return( as_json(errors) ) if errors.any?
  errors = require_params( %w(tldr) )
  status 400 and return( as_json(errors) ) if errors.any?

  status 201
  if request_body['parent_id']
    File.read("fixtures/create_post_reply.json")
  else
    File.read("fixtures/create_post_root.json")
  end
end


# Post #show
get '/posts/:id' do
  content_type :json

  status 200
  File.read("fixtures/show_post.json")
end


# Post context
get '/posts/:id/context' do
  content_type :json

  status 200
  File.read("fixtures/posts_by_context.json")
end


# Post top
get '/posts' do
  content_type :json

  status 200
  File.read("fixtures/posts_top.json")
end


# Vote on a post
# Unvote if vector == 0
post '/votes' do
  content_type :json

  errors = require_auth_header
  status 401 and return( as_json(errors) ) if errors.any?
  errors = require_params( %w(post_id vector) )
  status 400 and return( as_json(errors) ) if errors.any?

  status 200
  if request_body['vector'] == 0
    File.read("fixtures/delete_vote.json")
  else
    File.read("fixtures/create_vote.json")
  end
end
