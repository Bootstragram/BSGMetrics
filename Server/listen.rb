require 'sinatra/base'
require 'json'

CERT_PATH = './'

webrick_options = {
  :Host => "0.0.0.0",
  :Port => 4567
}

class MyServer < Sinatra::Base
    post '/metrics/activities' do
      puts "* Params: "
      puts params
      puts request.body.read

      content_type :json
      { :key1 => 'value1', :key2 => 'value2' }.to_json
    end

    get '/metrics/activities' do
      content_type :text
      "BSGMetrics up"
    end
end

# Run the Sinatra application using WEBrick
MyServer.run! webrick_options
