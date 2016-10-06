require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'json'

CERT_PATH = './'

webrick_options = {
  :Host => "0.0.0.0",
  :Port => 4567
}

class MyServer  < Sinatra::Base
    post '/' do
      puts "* Params: "
      puts params
      puts request.body.read

      content_type :json
      { :key1 => 'value1', :key2 => 'value2' }.to_json
    end

    get '/' do
      content_type :text
      "BSGMetrics up"
    end
end

Rack::Handler::WEBrick.run MyServer, webrick_options
