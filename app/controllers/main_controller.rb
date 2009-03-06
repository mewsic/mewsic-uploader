class MainController < ApplicationController
  skip_before_filter :check_auth

  def index
    redirect_to MAIN_SERVER, :status => :moved_permanently
  end
end
