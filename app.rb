require './config/application'

Cuba.define do
  begin
    def current_user
      @current_user ||= User[session[:user_id].to_i] ||
        raise(StandardError, 'The user is not logged in.')
    end

    def json_body
      @json_body ||= JSON.parse req.body.gets, symbolize_names: true
    end

    res.headers['Content-Type'] = 'application/json'

    on 'movements' do
      current_user

      on ':id' do |id|
        movement ||= Movement[id] ||
          raise(TypeError, "Movement doesn't exists with that id.")

        on get do
          res.write movement.to_hash.to_json
        end

        on put do
          if movement.update(json_body[:movement])
            res.status = 204
          else
            res.write errors: "You can't make any action in a movement with an old date."
            res.status = 403
          end
        end

        on delete do
          movement.delete
          res.status = 204
          res.redirect '/movements'
        end
      end

      on root do
        on get do
          movements = Movement.sort_by_date.map(&:to_hash).to_json
          res.write movements
        end

        on post do
          movement = current_user.movements.add(Movement.create json_body[:movement])
          res.write movement.to_hash
          res.status = 201
        end
      end

    end

    on post, 'login' do
      user = User.login json_body[:user]
      if user
        session[:user_id] = user.id
        res.write user.to_hash.to_json
        res.status = 200
      else
        res.write errors: 'Your user or password was incorrect.'
        res.status = 302
      end
    end

    on get, 'logout' do
      res.status = 204
    end

  rescue TypeError => e
    on true do
      res.status = 404
      res.write errors: e.message
    end

  rescue StandardError => e
    on true do
      res.status = 401
      res.write errors: e.message
    end
  end
end
