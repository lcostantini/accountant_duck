module UserHelpers
  def login_if_user_not_logged
    res.redirect '/login' unless current_user
  end

  def current_user
    session[:user]
  end
end
