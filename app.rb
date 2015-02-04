require './config/application'

Cuba.define do
  #login_if_user_not_logged

  on root do
    render 'add_movement', movement: Movement.new
    on param('movement') do |params|
      params['user'] = current_user
      Movement.create params
      res.redirect '/'
    end
    res.write partial 'index', movements: Movement.all.to_a
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
end
