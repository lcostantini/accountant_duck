require "./config/#{ ENV['RACK_ENV'] || 'development' }"

Ohm.redis = Redic.new ENV['REDISTOGO_URL']

Dir["./models/*.rb"].each { |rb| require rb }
Dir["./helpers/*.rb"].each { |rb| require rb }
