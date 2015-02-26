require "./config/#{ ENV['RACK_ENV'] || 'development' }"

require 'cuba'
require 'cuba/render'
require 'rack/protection'
require 'slim'
require 'ohm'
require 'digest/sha2'

Dir["./models/*.rb"].each { |rb| require rb }
Dir["./helpers/*.rb"].each { |rb| require rb }

Ohm.redis = Redic.new(ENV['REDISCLOUD_URL'] || 'redis://127.0.0.1:6379')

Cuba.use Rack::Session::Cookie, secret: '__a_very_long_string__'
Cuba.use Rack::Protection
Cuba.use Rack::Protection::RemoteReferrer
Cuba.use Rack::Static, urls: ['/css', '/img'], root: 'public'
Cuba.plugin Cuba::Render
Cuba.plugin UserHelpers
Cuba.settings[:render][:template_engine] = 'slim'
