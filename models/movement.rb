class Movement < Ohm::Model
  attribute :created_at
  attribute :description
  attribute :price
  attribute :type

  index :created_at
  index :type

  def initialize atts = {}
    super
    self.created_at ||= Time.now.strftime('%D')
    self.type ||= 'Deposit'
  end

  def to_hash
    super.merge self.attributes
  end
end
