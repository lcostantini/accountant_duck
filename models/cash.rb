class Cash < Ohm::Model
  attribute :total

  @@instance = Cash.new total: 0

  def self.instance
    return @@instance.save
  end

  def set_total price, type
    operator = { 'Deposit' => '+', 'Extraction' => '-' }
    self.total = (self.total.method operator[type]).call price.to_f
  end

  private_class_method :new
end
