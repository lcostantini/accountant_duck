require 'cuba/test'
require './app'

scope do
  test 'user not logged' do
    get '/'
    follow_redirect!
    assert_equal 'autenticate', last_response.body
  end

  test 'user is logged' do
    get '/'
    assert_equal 'hola', last_response.body
  end
end
