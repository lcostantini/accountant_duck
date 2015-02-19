class Movement < Ohm::Model
  attribute :user
  attribute :created_at
  attribute :description
  attribute :price
  attribute :type

  index :user
  index :created_at

  def save
    price_for_deposit_or_extraction
    self.type = self.type.downcase
    self.created_at = Time.now.strftime("%D") if self.created_at.empty?
    super
  end

  def price_for_deposit_or_extraction
    self.price = delete_minus
    self.price = "-#{self.price}" if self.type == "Extraction"
  end

  def delete_minus
    if self.price[0] == "-"
      self.price[1..-1]
    else
      self.price
    end
  end
end
