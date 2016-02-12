def current_user
  @user ||= User.with :name, 'alagranja'
  pwd = Digest::SHA256.hexdigest 'alagranja'
  @user ||= User.create name: 'alagranja', password: "#{ pwd }"
end

def deposit
  current_user.movements.add Movement.create price: '300000', type: 'Deposit'
end

def mock_session
  get '/movements', {}, { 'rack.session' => { user_id: current_user.id } }
end

def movement_body
  { movement: { price: '300000',
                description: 'increase',
                type: 'Deposit' } }.to_json
end

def update_body
  { movement: { price: '100000' } }.to_json
end

def body_json
  JSON.parse last_response.body, symbolize_names: true
end

scope 'user not logged' do
  test 'fail to create a movement' do
    post '/movements', movement_body
    assert_equal 401, last_response.status
  end

  test 'fail to update a movement' do
    put "/movements/#{ deposit }", update_body
    assert_equal 401, last_response.status
  end

  test 'fail to delete a movement' do
    delete "/movements/#{ deposit }"
    assert_equal 401, last_response.status
  end

  test 'fail to get a movement' do
    get "/movements/#{ deposit }"
    assert_equal 401, last_response.status
  end
end

scope 'user logged' do
  mock_session

  test 'show a movement' do
    get "/movements/#{ deposit }"
    assert_equal 200, last_response.status
    assert_equal body_json[:id].to_i, current_user.movements[deposit].id
  end

  test 'get an error when try to access a movement with a non existing id' do
    get '/movements/404'
    assert_equal 404, last_response.status
  end

  test 'show all movements' do
    deposit
    get '/movements'
    assert_equal 200, last_response.status
    assert_equal body_json.first[:id].to_i, current_user.movements[deposit].id
  end

  test 'create a movement' do
    post '/movements', movement_body
    assert_equal 1, current_user.movements.count
    assert_equal 201, last_response.status
    assert_equal body_json[:id].to_s, current_user.movements.to_a.last.id
  end

  test 'update a movement' do
    put "/movements/#{ deposit }", update_body
    assert_equal '100000', current_user.movements[deposit].price
    assert_equal 204, last_response.status
  end

  test 'delete a movement' do
    delete "/movements/#{ deposit }"
    assert_equal 0, current_user.movements.count
    assert_equal 302, last_response.status
  end
end
