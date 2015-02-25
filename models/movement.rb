class Movement < Ohm::Model
  attribute :created_at
  attribute :description
  attribute :price
  attribute :type

  index :created_at
  index :type
  reference :user, :User

  def save
    self.created_at = Time.now if self.created_at.nil?
    return false unless valid?
    super
  end

  private

  def valid?
    return true if new?
    created_at[0..9] > (Time.now - 60 * 60 * 24).to_s[0..9]
  end
end
