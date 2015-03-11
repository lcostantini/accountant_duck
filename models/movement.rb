class Movement < Ohm::Model
  attribute :created_at
  attribute :description
  attribute :price
  attribute :type

  index :created_at
  index :type
  reference :user, :User

  def save
    self.created_at = Time.now.strftime('%D') if self.created_at.nil?
    Cash.instance.set_total self.price, self.type if new?
    return false unless valid?
    unless new?
      price = self.price.to_i - Movement[self.id].price.to_i
      Cash.instance.set_total price.abs, self.type
    end
    super
  end

  def delete
    return false unless valid?
    type = %w(Deposit Extraction).reject { |m| m == "#{self.type}" }.first
    Cash.instance.set_total self.price.to_i, type
    super
  end

  private

  def valid?
    return true if new?
    created_at > (Time.now - 60 * 60 * 24).strftime('%D')
  end
end
