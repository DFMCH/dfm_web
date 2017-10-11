class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  def index
  end

  def news
  end

  def pure
  end

  def paper
  end

  def paper_notice
    flash.now[:notice] = "This is a notice message"
    render :paper
  end

  def paper_alert
    flash.now[:alert] = "This is an alert message\nIt's intentionally really long.  You have some errors with your form.  You should fix them."
    render :paper
  end

  def notice
    flash.now[:notice] = "This is a notice message"
    render :index
  end

  def alert
    flash.now[:alert] = "This is an alert message"
    render :index
  end

end
