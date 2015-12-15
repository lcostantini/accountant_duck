require './config/application'

Cuba.define do
  begin
    def current_user
      @current_user ||= User[session[:user_id].to_i] || raise(StandardError, 'The user is not logged in.')
    end

    def json_body
      @json_body ||= JSON.parse req.body.gets, symbolize_names: true
    end

    def what_response? response
      if response
        res.status = 204
      else
        res.write errors: "You can't make any action in a movement with an old date."
        res.status = 403
      end
    end

    res.headers['Content-Type'] = 'application/json'

    on 'movements' do
      current_user

      on ':id' do |id|
        movement ||= Movement[id] || raise(StandardError, "Movement doesn't exists with that id.")

        on get do
          res.write movement.attributes.to_json
        end

        on put do
          what_response?(movement.update json_body[:movement])
        end

        on delete do
          movement.delete
          res.status = 204
          res.redirect '/movements'
        end
      end

      on root do
        on get do
          movements = Movement.all.sort_by(:created_at, order: 'ALPHA ASC').to_a.map { |m| m.attributes.merge id: m.id }.to_json
          res.write movements
        end

        on post do
          movement = current_user.movements.add(Movement.create json_body[:movement])
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

    on get, 'me' do
      res.write current_user.attributes.to_json
    end

  rescue StandardError => e
    on true do
      res.status = 401
      res.write errors: e.message
    end
  end
end
