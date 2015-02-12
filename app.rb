require './config/application'

Cuba.define do
  on root do
    if current_user
      render 'form_movement', movement: Movement.new
      on param 'movement' do |params|
        params['user'] = current_user
        Movement.create params
        res.redirect '/'
      end
      res.write partial 'index', movements: Movement.all.to_a
    else
      render 'index', movements: Movement.all.to_a
    end
  end

  on "edit/:id" do |id|
    if can_use_actions? Movement[id].created_at
      render 'form_movement', movement: Movement[id]
      on param 'movement' do |params|
        Movement[id].update params
        res.redirect '/'
      end
    else
      res.status = 401
      render "#{res.status}"
    end
  end

  on "delete/:id" do |id|
    if can_use_actions? Movement[id].created_at
      Movement[id].delete
      res.redirect '/'
    else
      res.status = 401
      render "#{res.status}"
    end
  end

  on 'login' do
    render 'form_login', user: User.new
    on param 'user' do |params|
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
