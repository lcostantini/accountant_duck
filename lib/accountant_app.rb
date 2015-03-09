def current_user
  @current_user ||= User[session[:user_id]] || false
end

class AccountanApp < Cuba
  define do
    on get, root do
      res.redirect '/movements'
    end

    on 'movements' do
      on ':id' do |id|
        movement = Movement[id]
        if can_use_actions? movement.created_at
          set_req_method
          on get do
            render 'edit', movement: movement
          end
          on put, param('movement') do |params|
            movement.update params
            res.redirect '/movements'
          end
          on delete do
            movement.delete
            res.redirect '/movements'
          end
        else
          res.status = 403
          render "#{res.status}"
        end
      end
      on root do
        if current_user
          on get do
            render 'new', movement: Movement.new
            res.write partial 'index', movements: Movement.all.to_a
          end
          on post, param('movement') do |params|
            current_user.build_movement(params).save
            res.redirect '/movements'
          end
        else
          render 'index', movements: Movement.all.to_a
        end
      end
    end

    on 'session' do
      on get do
        on 'new' do
          render 'form_login', user: User.new
          session.delete :notice
        end
        on root do
          session.delete :user_id
          res.redirect '/movements'
        end
      end
      on post, 'new', param('user') do |params|
        user = User.login params
        if user
          session[:user_id] = user.id
          res.redirect '/movements'
        else
          res.status = 302
          session[:notice] = 'Your user or password was incorrect.'
          res.redirect '/session/new'
        end
      end
    end
  end
end
