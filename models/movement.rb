class Movement < Ohm::Model
  attribute :created_at
  attribute :description
  attribute :price
  attribute :type

  index :created_at
  index :type
  reference :user, :User

  def initialize atts = {}
    super
    self.created_at ||= Time.now.strftime('%D')
    self.type ||= 'Deposit'
  end

  def save
    return false unless valid?
    update_cash
    super
  end

  def delete
    return false unless valid?
    type = %w(Deposit Extraction).reject { |m| m == type.to_s }.first
    Cash.instance.set_total price.to_i, type
    super
  end

  def self.sort_by_date
    self.all.sort_by(:created_at, order: 'ALPHA ASC').to_a
  end

  def to_hash
    super.merge self.attributes
  end

  private

  def valid?
    return true if new?
    created_at > (Time.now - 60 * 60 * 24).strftime('%D')
  end

  def update_cash
    cash_price = price.to_i - Movement[id].price.to_i unless new?
    cash_price ||= price.to_i
    Cash.instance.set_total cash_price.to_i.abs, type
  end

end
