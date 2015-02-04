class Movement < Ohm::Model
  attribute :user
  attribute :created_at
  attribute :description
  attribute :price

  index :user
  index :created_at
end
