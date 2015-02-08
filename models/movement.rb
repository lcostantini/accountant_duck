class Movement < Ohm::Model
  attribute :user
  attribute :created_at
  attribute :description
  attribute :price
  attribute :movement

  index :user
  index :created_at

  def save
    self.price = "-#{self.price}" if self.movement == "Extraction"
    self.movement = self.movement.downcase
    self.created_at = Time.now.strftime("%D") if self.created_at.empty?
    super
  end
end
