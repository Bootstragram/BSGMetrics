require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'json'

CERT_PATH = './'

webrick_options = {
        :Port               => 4567,
        # :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        # :SSLEnable          => true,
        # :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        # :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "server.crt")).read),
        # :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "server.key")).read),
        # :SSLCertName        => [ [ "CN", WEBrick::Utils::getservername ] ]
}

class MyServer  < Sinatra::Base
    post '/' do
      puts "* Params: "
      puts params
      puts request.body.read

      content_type :json
      { :key1 => 'value1', :key2 => 'value2' }.to_json
    end
end

Rack::Handler::WEBrick.run MyServer, webrick_options
