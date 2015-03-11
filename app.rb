require './config/application'

Cuba.define do
  begin
    def current_user
      @current_user ||= User[session[:user_id]] || raise(StandardError, 'The user is not logged.')
    end

    def json_body
      JSON.parse req.body.gets
    end

    res.headers['Content-Type'] = 'application/json'
    on 'api/movements' do

      on ':id' do |id|
        current_user
        movement ||= Movement[id] || raise(NilClass, "Movement doesn't exists with that id.")

        on get do
          res.write movement.attributes.to_json
        end

        on put do
          res.write movement.update json_body['movement']
        end

        on delete do
          movement.delete
        end
      end

      on root do
        on get do
          movements = Movement.all.to_a.map do |m|
            (m.attributes.merge id: m.id)
          end
          res.write movements.to_json
        end

        on post do
          movement = current_user.build_movement(json_body['movement']).save
          res.write movement.id
        end
      end

    end

    on 'api/login', post do
      user = User.login json_body['user']
      if user
        session[:user_id] = user.id
        res.write "id: #{ user.id }"
      else
        res.write errors: 'Your user or password was incorrect.'
        res.status = 302
      end
    end

    on 'api/logout', delete do
      res.write session.delete :user_id
    end

    on get, 'me' do
      res.write current_user.attributes.to_json
    end

  rescue StandardError, NilClass => e
    on true do
      res.status = 401
      res.write errors: e.message
    end
  end

  on default do
    run AccountantApp
  end
end
