def login_body
  { user: { name: 'alagranja',
            password: 'alagranja' } }.to_json
end

def invalid_login_body
  { user: { name: 'alagranja',
            password: 'bad_password' } }.to_json
end

scope do
  test 'login user' do
    post 'login', login_body
    @user = User.with :name, 'alagranja'
    assert_equal @user.id, last_request.session[:user_id]
    assert_equal 200, last_response.status
  end

  test 'logout user' do
    delete 'logout'
    assert last_request.session[:user_id].nil?
  end

  test 'invalid credentials when user login' do
    post 'login', invalid_login_body
    assert_equal 302, last_response.status
  end
end
