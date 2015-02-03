require 'cuba/test'
require './app'

scope do
  test 'user not authenticated' do
    get '/'
    follow_redirect!
    assert_equal 'autenticate', last_response.body
  end

  test 'user is authenticated' do
    get '/'
    assert_equal 'hola', last_response.body
  end
end
