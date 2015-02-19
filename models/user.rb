class User < Ohm::Model
  attribute :name
  attribute :password

  unique :name
end
