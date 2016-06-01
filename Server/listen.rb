require 'sinatra'
require 'json'

post '/' do
  puts "* Params: "
  puts params
  puts request.body.read

  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
end
