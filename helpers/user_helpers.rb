module UserHelpers
  def current_user
    session[:user]
  end

  def calculate_total
    return "0" if Movement.all.to_a.empty?
    Movement.all.to_a.map do |mov|
      mov.price.to_f
    end.inject(:+).round(3)
  end
end
