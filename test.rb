ENV['HEROKU_REDIS_CRIMSON_URL'] = 'redis://localhost:6379/2'
require './app'
require 'cuba/test'
require 'cutest'
require 'pry'

prepare do
  Ohm.flush
  pwd = Digest::SHA256.hexdigest 'alagranja'
  User.create name: 'alagranja', password: "#{pwd}"
end

Dir["./tests/*.rb"].each { |rb| require rb }
