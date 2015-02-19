require './config/application'

Cuba.define do
  on 'movements' do
    on ':id' do |id|
      movement = Movement[id]
      on get do
        render 'form_movement', movement: movement
      end
      on put do
        on param 'movement' do |params|
          if can_use_actions? movement.created_at
            movement.update params
            res.redirect 'movements'
          else
            res.status = 401
            render "#{res.status}"
          end
        end
      end
      on delete do
        if can_use_actions? movement.created_at
          movement.delete
          res.redirect 'movements'
        else
          res.status = 401
          render "#{res.status}"
        end
      end
    end

    on root do
      on get do
        if current_user
          render 'form_movement', movement: Movement.new
          res.write partial 'index', movements: Movement.all.to_a
        else
          render 'index', movements: Movement.all.to_a
        end
      end
      on post do
        on param 'movement' do |params|
          params['user'] = current_user
          Movement.create params
          res.redirect 'movements'
        end
      end
    end
  end

  on 'session' do
    on get do
      on 'login' do
        render 'form_login', user: User.new
      end
      on 'logout' do
        session.delete 'user'
        res.write 'movements'
      end
    end

    on post, 'login' do
      on param 'user' do |params|
        user = User.with :name, params['name']
        if user && user.password == params['password']
          session[:user] = user.id
        end
      end
    end
  end
end
