module UserHelpers
  def current_user
    @current_user ||= User[session[:user_id]]
  end

  def can_use_actions? created_at
    current_user && created_at == Time.now.strftime('%D')
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
