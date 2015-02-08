module UserHelpers
  def current_user
    session[:user]
  end

  def calculate_total
    Movement.all.to_a.map do |mov|
      mov.price.to_i
    end.inject(:+)
  end
end
