require 'cuba'
require 'cuba/render'
require 'rack/protection'
require 'slim'
require 'ohm'
require 'pry'

Dir["./models/*.rb"].each { |rb| require rb }
Dir["./helpers/*.rb"].each { |rb| require rb }

Cuba.use Rack::Session::Cookie, secret: '__a_very_long_string__'
Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer
Cuba.plugin Cuba::Render
Cuba.plugin UserHelpers
Cuba.settings[:render][:template_engine] = 'slim'

