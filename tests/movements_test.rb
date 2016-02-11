def current_user
  @user ||= User.with :name, 'alagranja'
  pwd = Digest::SHA256.hexdigest 'alagranja'
  @user ||= User.create name: 'alagranja', password: "#{ pwd }"
end

def deposit
  Movement.create price: '300000', type: 'Deposit'
end

def old_deposit
  yesterday = (Time.now - 60 * 60 * 24).strftime('%D')
  Movement.create price: '10000', type: 'Deposit', created_at: yesterday
end

def extraction
  Movement.create price: '310025', type: 'Extraction'
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
    put "/movements/#{ deposit.id }", update_body
    assert_equal 401, last_response.status
  end

  test 'fail to delete a movement' do
    delete "/movements/#{ deposit.id }"
    assert_equal 401, last_response.status
  end

  test 'fail to get a movement' do
    get "/movements/#{ deposit.id }"
    assert_equal 401, last_response.status
  end
end

scope 'user logged' do
  mock_session
  deposit

  test 'show a movement' do
    get "/movements/#{ deposit.id }"
    assert_equal 200, last_response.status
    assert_equal body_json[:price], deposit.attributes[:price]
  end

  test 'get an error when try to access a movement with a non existing id' do
    get '/movements/7'
    assert_equal 401, last_response.status
  end

  test 'show all movements' do
    id = deposit.id
    get '/movements'
    assert_equal 200, last_response.status
    assert_equal body_json.first[:price], Movement[id].price
  end

  test 'create a movement' do
    post '/movements', movement_body
    assert_equal 1, Movement.all.count
  end

  test 'update a movement' do
    id = deposit.id
    put "/movements/#{ id }", update_body
    assert_equal '100000', Movement[id].price
  end

  test 'delete a movement' do
    delete "/movements/#{ deposit.id }"
    assert_equal 0, Movement.all.count
  end

  test 'fail to delete a movement with an old date' do
    delete "/movements/#{ old_deposit.id }"
    assert_equal 302, last_response.status
  end

  test 'fail to update a movement with an old date' do
    put "/movements/#{ old_deposit.id }", update_body
    assert_equal 403, last_response.status
  end
end
