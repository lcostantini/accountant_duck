class Cash < Ohm::Model
  counter :total

  @@instance = Cash.new

  def self.instance
    return @@instance.save
  end

  def set_total price, type
    operator = { 'Deposit' => :incr, 'Extraction' => :decr }
    self.send operator[type], :total, price
  end

  private_class_method :new
end
