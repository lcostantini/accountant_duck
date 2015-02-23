module UserHelpers
  def current_user
    @current_user ||= User[session[:user_id]]
  end

  def calculate_total
    return "0" if Movement.all.to_a.empty?
    Movement.all.to_a.map do |mov|
      mov.price.to_f
    end.inject(:+).round(3)
  end

  def can_use_actions? created_at
    current_user && created_at == Time.now.strftime("%D")
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
