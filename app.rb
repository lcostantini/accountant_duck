require './config/application'

Cuba.define do
  begin
    def current_user
      @current_user ||= User[session[:user_id]] || raise(StandardError, 'The user is not logged.')
    end

    def json_body
      #TODO: ver de que pueda usar simbolo
      JSON.parse req.body.gets
    end

    res.headers['Content-Type'] = 'application/json'
    on 'movements' do

      on ':id' do |id|
        current_user
        movement ||= Movement[id] || raise(NilClass, "Movement doesn't exists with that id.")

        on get do
          res.write movement.attributes.to_json
        end

        on put do
          response = movement.update json_body['movement']
          #TODO: fix this
          if response
            res.write response
          else
            res.status = 403
          end
        end

        on delete do
          response = movement.delete
          if response
            res.write response
          else
            res.status = 403
          end
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

    on 'login', post do
      user = User.login json_body['user']
      if user
        session[:user_id] = user.id
        res.write user.attributes.to_json
      else
        res.write errors: 'Your user or password was incorrect.'
        res.status = 302
      end
    end

    on 'logout', delete do
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
end
