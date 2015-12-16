class User < Ohm::Model
  attribute :name
  attribute :password

  unique :name
  collection :movements, :Movement

  def self.login credentials
    user = User.with :name, credentials[:name]
    return user if user.password == Digest::SHA256.hexdigest(credentials[:password])
  end

  def to_hash
    super.merge self.attributes
  end
end
