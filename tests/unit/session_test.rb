def current_user
  @user ||= User.with :name, 'alagranja'
end

scope do
  test 'login user' do
    post '/session/new', { user: { name: 'alagranja', password: 'alagranja' } }
    follow_redirect!
    assert_equal current_user.id, last_request.session[:user_id]
  end

  test 'logout user' do
    get '/session'
    follow_redirect!
    assert last_request.session[:user_id].nil?
  end

  test 'invalid credentials when user login' do
    post '/session/new', { user: { name: 'alagranja', password: 'bad_password' } }
    notice = 'Your user or password was incorrect.'
    assert_equal notice, last_request.session[:notice]
    assert_equal 302, last_response.status
  end
end
