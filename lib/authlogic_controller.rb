#
# Cleans up the app controller
#
# Intended as a superclass of  ApplicationController
#   i.e.  ApplicationController < AuthlogicController
#
class AuthlogicController < ActionController::Base
  helper_method :current_user_session, :current_user

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user ||= current_user_session && current_user_session.record
    session[:username] = @current_user.username if @current_user
    @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_admin
    unless current_user.role?(:admin)
      store_location
      flash[:notice] = "You must be admin to access that page"
      redirect_to reporter_dashboard_url
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:error] = "You must be logged out to access requested page"
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end

