def current_user
  @current_user ||= User[session[:user_id]] || raise(StandardError, 'The user is not logged.')
end

def deposit
  Movement.create price: 300000, type: 'Deposit'
end

scope do
  test 'login user' do
    post 'login', { 'user' => { 'name' => 'alagranja', 'password' => 'alagranja' } }.to_json
    @user ||= User.with :name, 'alagranja'
    assert_equal @user.id, last_request.session[:user_id]
    assert_equal 200, last_response.status
  end

  test 'logout user' do
    delete 'logout'
    assert last_request.session[:user_id].nil?
  end

  test 'invalid credentials when user login' do
    post 'login', { 'user' => { 'name' => 'alagranja', 'password' => 'bad_password' } }.to_json
    assert_equal 302, last_response.status
  end
end
