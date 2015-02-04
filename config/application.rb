require 'cuba'
require 'cuba/render'
require 'rack/protection'
require 'slim'
require 'ohm'
require 'pry'

Cuba.use Rack::Session::Cookie, secret: '__a_very_long_string__'
Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer
Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = 'slim'

Dir["./models/*.rb"].each  { |rb| require rb  }
