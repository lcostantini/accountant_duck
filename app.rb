require './config/application'

Cuba.define do
  begin
    def current_user
      @current_user ||= User[session[:user_id]] || raise(StandardError, 'The user is not logged.')
    end

    on 'api/movements' do
      res.headers['Content-Type'] = 'application/json'

      on ':id' do |id|
        movement = Movement[id]

        on get do
          res.write movement: movement.attributes.to_json
        end

        on put do
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

        on post do
          movement = current_user.build_movement(params['movement']).save
          res.write movement: movement.id
        end
      end

    end

    on 'api/login', post do
      params = JSON.parse req.body.gets
      user = User.login params['user']
      if user
        res.write session[:user_id] = user.id
      else
        res.status = 302
      end
    end

    on 'api/logout', delete do
      session.delete :user_id
    end

    on get, 'me' do
      res.write current_user.attributes.to_json
    end

  rescue StandardError => e
    on true do
      res.status = 401
      res.write errors: e.message
    end
  end

  on default do
    run AccountantApp
  end
end
