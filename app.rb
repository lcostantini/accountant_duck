require 'cuba'
require 'rack/protection'

Cuba.use Rack::Session::Cookie,
  secret: "__a_very_long_string__"
Cuba.use Rack::Protection

Cuba.define do
  on get do
    unless session[:user]
      res.redirect '/authentication'
    end

    on 'authentication' do
      res.write 'autenticate'
    end

    on root do
      res.write 'hola'
    end
  end
end
