class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def index
  end

  def news
  end

  def notice
    flash[:notice] = "This is a notice message"
    redirect_to root_url
  end

  def alert
    flash[:alert] = "This is an alert message"
    redirect_to root_url
  end

end
