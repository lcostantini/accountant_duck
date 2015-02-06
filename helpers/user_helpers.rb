module UserHelpers
  def current_user
    session[:user]
  end
end
