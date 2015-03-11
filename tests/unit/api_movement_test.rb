def current_user
  @user ||= User.with :name, 'alagranja'
  pwd = Digest::SHA256.hexdigest 'alagranja'
  @user ||= User.create name: 'alagranja', password: "#{pwd}"
end

def deposit
  Movement.create price: 300000, type: 'Deposit'
end

def old_deposit
  yesterday = (Time.now - 60 * 60 * 24).strftime('%D')
  Movement.create price: 10000, type: 'Deposit', created_at: yesterday
end

def extraction
  Movement.create price: 310025, type: 'Extraction'
end

def mock_session
  get '/movements', {}, { 'rack.session' => { user_id: current_user.id } }
end

scope 'user not logged' do
  test 'fail to create a movement' do
    post '/movements', { 'movement' => { 'price' => '300000', 'description' => 'increase', 'type' => 'Deposit' } }.to_json
    assert_equal 401, last_response.status
  end

  test 'fail to update a movement' do
    id = deposit.id
    put "/movements/#{ id }", { 'movement' => { 'price' => '100000' } }.to_json
    assert_equal 401, last_response.status
  end

  test 'fail to delete a movement' do
    id = deposit.id
    delete "/movements/#{ id }"
    assert_equal 401, last_response.status
  end

  test 'fail to get a movement' do
    id = deposit.id
    get "/movements/#{ id }"
    assert_equal 401, last_response.status
  end
end

scope 'user logged' do
  mock_session

  test 'show a movement' do
    #TODO: devolver objeto
    id = deposit.id
    get "/movements/#{ id }"
    assert_equal 200, last_response.status
  end

  test 'create a movement' do
    post '/movements', { 'movement' => { 'price' => '300000', 'description' => 'increase', 'type' => 'Deposit' } }.to_json
    assert_equal 1, Movement.all.count
  end

  test 'update a movement' do
    id = deposit.id
    put "/movements/#{ id }", { 'movement' => { 'price' => '10000' } }.to_json
    assert_equal 10000, Movement[id].price.to_i
  end

  test 'delete a movement' do
    id = deposit.id
    delete "/movements/#{ id }"
    assert_equal 0, Movement.all.count
  end

  test 'fail to delete a movement with an old date' do
    id = old_deposit.id
    delete "/movements/#{ id }"
    assert_equal 403, last_response.status
  end

  test 'fail to update a movement with an old date' do
    id = old_deposit.id
    put "/movements/#{ id }", { 'movement' => { 'price' => '10000' } }.to_json
    assert_equal 403, last_response.status
  end
end

scope do
  test 'show all movements' do
    #TODO: devolver objeto
    get '/movements'
    assert_equal 200, last_response.status
  end

  test 'get a movement with a non existing id' do
    get '/movements/7'
    assert_equal 401, last_response.status
  end
end
