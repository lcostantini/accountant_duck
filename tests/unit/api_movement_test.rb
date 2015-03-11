def deposit
  Movement.create price: 300000, type: 'Deposit'
end

def old_deposit
  yesterday = (Time.now - 60 * 60 * 24).strftime('%D')
  Movement.create price: 10000, type: 'Deposit', created_at: yesterday
end

scope do
  test 'fail to create a movement when user is not logged' do
    post 'api/movements', { 'movement' => { 'price' => '300000', 'description' => 'increase', 'type' => 'Deposit' } }.to_json
    assert_equal 401, last_response.status
  end

  test 'fail to update a movement when user is not logged' do
    id = deposit.id
    put "api/movements/#{ id }", { 'movement' => { 'price' => '100000' } }.to_json
    assert_equal 401, last_response.status
  end

  test 'fail to delete a movement with an old date' do
    id = old_deposit.id
    delete "api/movements/#{ id }"
    assert_equal 401, last_response.status
  end

  test 'get a movement with a non existing id' do
    get "api/movements/7"
    assert_equal 401, last_response.status
  end
end
