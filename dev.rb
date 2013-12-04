require 'webrick'
require 'webrick/https'
require './starter.rb'

CERT_PATH = '/Users/Jack/.ssl/'

webrick_options = {
  :Port               => 8443,
  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot       => "Interfolio/sinatra-backbone-requirejs/",
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "interfolio.cert.crt")).read),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "interfolio.cert.key")).read),
  :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ],
  :app                => Starter
}

Rack::Server.start webrick_options
