class User < Ohm::Model
  attribute :user_name
  attribute :password

  unique :user_name
end
