class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def index
  end

  def form_submit
    sleep 2
    redirect_to root_url
  end

  def news
  end

  def pure
  end

  def notice_example
    flash[:notice] = "This is a notice message.<br>It can be <i>long</i> and include <b>basic</b> HTML."
    redirect_to root_url
  end

  def alert_example
    flash[:alert] = "This is an alert message"
    redirect_to root_url
  end

end
