class User < Ohm::Model
  attribute :name
  attribute :password

  unique :name

  def self.login credentials
    user = User.with :name, credentials['name']
    return user if user.password == credentials['password']
  end
end
