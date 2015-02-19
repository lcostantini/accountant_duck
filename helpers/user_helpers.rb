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
    if req.fullpath.end_with? "delete="
      env["REQUEST_METHOD"] = "DELETE"
    else
      env["REQUEST_METHOD"] = "PUT"
    end
  end
end
