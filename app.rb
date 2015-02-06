require './config/application'

Cuba.define do
  on root do
    if current_user
      render 'add_movement', movement: Movement.new
      on param('movement') do |params|
        params['user'] = current_user
        Movement.create params
        res.redirect '/'
      end
      res.write partial 'index', movements: Movement.all.to_a
    else
      render 'index', movements: Movement.all.to_a
    end
  end

  on 'login' do
    render 'login', user: User.new
    on param('user') do |params|
      user = User.with :user_name, params['name']
      if user && user.password == params['password']
        session[:user] = user.id
        res.redirect '/'
      end
    end
  end

  on 'logout' do
    session.delete 'user'
    res.redirect '/'
  end
end
