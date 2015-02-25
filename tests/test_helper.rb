ENV['RACK_ENV'] = 'test'
ENV['REDISCLOUD_URL'] = 'redis://localhost:6379/2'
require './config/application'
require './app'

prepare do
  Ohm.flush
  #TODO: move the user create to the 'movement_test'
  User.create name: 'alagranja', password: 'alagranja'
end
