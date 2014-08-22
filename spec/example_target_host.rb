require 'sinatra'

get '/a-GET-request' do
  'here is my GET request'
end

get '/' do
  'here is my GET request to /'
end

get '/a-path' do
  "a GET request to /"
end

post '/' do
  params.inspect
end

put '/' do
  params.inspect
end

delete '/' do
  params.inspect
end

patch '/' do
  params.inspect
end


### a redirect scenario
get '/a-redirect' do
  redirect '/redirected-page'
end

get '/redirected-page' do
  'the redirected page'
end


get '/rewritten-path' do
 'You are at /rewritten-path'
end

get '/page' do
  params.inspect
end

post '/page' do
  params.inspect
end

get '/page-with-stuff' do
  '<a href="http://localhost/rewritten-path?rewrote+with+SPACE">' \
  'rewrote with SPACE'
end
