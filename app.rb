require 'sinatra'
require 'pry'
require 'yajl'

helpers do
  def request_body
    @request_body ||= Yajl::Parser.parse( request.body )
  end
end

get '/' do
  'Have a look at app.rb'
end


# User #create
post '/users/' do
  content_type :json

  if request_body['handle'].empty?
    status 400
    return { error: '"handle" param is required' }
  end

  status 201
  File.read("fixtures/create_user.json")
end
