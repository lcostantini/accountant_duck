require './config/application'

Cuba.define do
  on 'api/movements' do
    res.headers['Content-Type'] = 'application/json'

    on ':id' do |id|
      movement = Movement[id]

      on get do
        res.write movement: movement.attributes.to_json
      end

      on put, param('movement') do |params|
        movement.update params
        res.write status: 200
      end

      on delete do
        movement.delete
        res.write status: 200
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
        current_user.build_movement(params).save
        res.write status: 201
      end
    end

  end

  on default do
    run AccountanApp
  end
end
