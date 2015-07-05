require 'sinatra'
require 'pry'
require 'yajl'

helpers do
  def request_body
    @request_body ||= Yajl::Parser.parse( request.body )
  end

  def require_params(required_params)
    missing_attrs = required_params - request_body.keys
    if missing_attrs.any?
      { error: "Required params missing: #{ missing_attrs.join(', ') }" }
    else
      {}
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
post '/users/' do
  content_type :json

  errors = require_params( %w(handle) )
  status 400 and return( as_json(errors) ) if errors.any?

  status 201
  File.read("fixtures/create_user.json")
end


# Post #create
post '/posts/' do
  content_type :json

  errors = require_params( %w(body tldr) )
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
