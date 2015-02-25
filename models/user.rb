class User < Ohm::Model
  attribute :name
  attribute :password

  unique :name
  collection :movements, :Movement
  set :movements, Movement

  def self.login credentials
    user = User.with :name, credentials['name']
    return user if user.password == credentials['password']
  end

  def build_movement args
    Movement.new args.merge user: self
  end
end
