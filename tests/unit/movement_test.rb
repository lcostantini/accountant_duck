def current_user
  @user ||= User.with :name, 'alagranja'
  pwd = Digest::SHA256.hexdigest 'alagranja'
  @user ||= User.create name: 'alagranja', password: "#{pwd}"
end

def deposit
  Movement.create price: 3000, type: 'Deposit'
end

def old_deposit
  yesterday = (Time.now - 60 * 60 * 24).strftime('%D')
  Movement.create price: 100, type: 'Deposit', created_at: yesterday
end

def extraction
  Movement.create price: 3100.25, type: 'Extraction'
end

def mock_session
  get '/movements', {}, { 'rack.session' => { user_id: current_user.id } }
end

scope do
  mock_session

  test 'show all movements' do
    get '/movements'
    assert_equal 200, last_response.status
  end

  test 'show a movement' do
    id = deposit.id
    get "/movements/#{id}"
    assert_equal 200, last_response.status
  end

  test 'show all movements for current_user' do
    #TODO
  end

  test 'create a movement' do
    post '/movements', { movement: { price: 3000, description: 'increase', type: 'Deposit' } }
    assert_equal 1, Movement.all.count
  end

  test 'update a movement' do
    id = deposit.id
    put "/movements/#{id}", { movement: { price: 100 } }
    assert_equal 100, Movement[id].price.to_i
  end

  test 'delete a movement' do
    id = deposit.id
    delete "/movements/#{id}"
    assert_equal 0, Movement.all.count
  end

  test 'not permited update or delete a movement' do
    id = old_deposit.id
    delete "/movements/#{id}"
    assert_equal 403, last_response.status
  end

  test 'calculace total with no movements' do
    assert_equal 0, Cash.instance.total
  end

  test 'calculate total, deposits only' do
    deposit
    assert_equal 3000, Cash.instance.total
  end

  test 'calculate total with many movements' do
    deposit
    old_deposit
    extraction
    assert_equal -0.25, Cash.instance.total
  end

  test 'calculate total when a deposit is update' do
    id = deposit.id
    extraction
    assert_equal -100.25, Cash.instance.total
    put "/movements/#{id}", { movement: { price: 3200 } }
    assert_equal 99.75, Cash.instance.total
  end

  test 'calculate total when a extraction is update' do
    deposit
    id = extraction.id
    assert_equal -100.25, Cash.instance.total
    put "/movements/#{id}", { movement: { price: 4000 } }
    assert_equal -1000, Cash.instance.total
  end

  test 'calculate total when a movement is delete' do
    id = deposit.id
    delete "/movements/#{id}"
    assert_equal 0, Cash.instance.total
  end

  test 'calculate total when multiple movement is delete' do
    deposit
    id = extraction.id
    delete "/movements/#{id}"
    assert_equal 3000, Cash.instance.total
  end
end
