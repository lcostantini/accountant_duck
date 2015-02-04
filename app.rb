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

def user_logged?
  res.redirect '/login' unless session[:user]
end

Cuba.define do
  #user_logged?

  on root do
    render 'index'
  end

  on 'login' do
    render 'login', user: User.new
    on param('user') do |params|
      user = User.with(:user_name, params['name'])
      if user && user.password == params['password']
        session[:user] = user.id
        res.redirect "/"
      end
    end
  end
end
