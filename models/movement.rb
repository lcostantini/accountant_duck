class Movement < Ohm::Model
  attribute :user
  attribute :created_at
  attribute :description
  attribute :price

  index :user
  index :created_at

  def save
    self.created_at = Time.now.strftime("%D") if self.created_at.empty?
    super
  end
end
