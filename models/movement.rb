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
    super
  end

  def delete
    return false unless valid?
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
end
