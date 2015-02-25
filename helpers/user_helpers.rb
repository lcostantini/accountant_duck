module UserHelpers
  def current_user
    @current_user ||= User[session[:user_id]]
  end

  def calculate_total
    %w(Extraction Deposit).map{ |type| all_prices_for_type type }.inject(:-)
  end

  def all_prices_for_type type
    return 0 if movement_have_type? "#{type}"
    (Movement.find type: "#{type}").map{ |movement| movement.price.to_f }.inject(:+)
  end

  def movement_have_type? type
    (Movement.find type: "#{type}").to_a.empty?
  end

  def can_use_actions? created_at
    current_user && created_at[0..9] == Time.now.strftime('%Y-%m-%d')
  end

  def date_value movement
    if movement.attributes.empty?
      Time.now.strftime("%D")
    else
      movement.created_at
    end
  end

  def is_deposit? movement
    movement.type == "deposit"
  end

  def set_req_method
    case
    when req.fullpath.end_with?("delete=")
      env["REQUEST_METHOD"] = "DELETE"
    when !(req.fullpath.delete req.path).empty?
      env["REQUEST_METHOD"] = "PUT"
    else
      env["REQUEST_METHOD"]
    end
  end
end
