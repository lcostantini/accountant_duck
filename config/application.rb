require 'cuba'
require 'ohm'
require 'digest/sha2'
require 'json'

Dir["./models/*.rb"].each { |rb| require rb }
Cuba.use Rack::Session::Cookie, secret: '__a_very_long_string__'
Ohm.redis = Redic.new(ENV['HEROKU_REDIS_CRIMSON_URL'] || 'redis://127.0.0.1:6379')

Cuba.use Rack::Static,
  :urls => ["/css", "/js", "/icons"],
  :root => 'public'

Cuba.use Rack::Static,
  :urls => "/",
  :root => 'public',
  :index => 'index.html'
