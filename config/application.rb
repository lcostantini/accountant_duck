require "./config/#{ ENV['RACK_ENV'] || 'development' }"

require 'cuba'
require 'ohm'
require 'digest/sha2'
require 'rack/cors'
require 'json'

Dir["./models/*.rb"].each { |rb| require rb }

Ohm.redis = Redic.new(ENV['REDISCLOUD_URL'] || 'redis://127.0.0.1:6379')
