require './config/application'

def current_user
  @current_user ||= User[session[:user_id]] || raise(StandardError, 'The user is not logged.')
end

Cuba.define do
  begin
    on 'api/movements' do
      res.headers['Content-Type'] = 'application/json'

      on ':id' do |id|
        movement = Movement[id]

        on get do
          res.write movement: movement.attributes.to_json
        end

        on put, param('movement') do |params|
          movement.update params
          res.status = 200
        end

        on delete do
          movement.delete
          res.status = 200
        end
      end

      on root do
        movements = Movement.all.to_a.map do |m|
          (m.attributes.merge id: m.id)
        end

        on get do
          res.write movements.to_json
        end

        on post, param('movement') do |params|
          movement = current_user.build_movement(params).save
          res.write movement: movement.id
        end
      end

    end

    on 'api/login', post, param('user') do |params|
      user = User.login params
      if user
        session[:user_id] = user.id
      else
        res.status = 302
      end
    end

    on 'api/logout', delete do
      session.delete :user_id
    end

    on default do
      run AccountanApp
    end

  rescue StandardError => e
    res.write errors: e.message
  end
end
