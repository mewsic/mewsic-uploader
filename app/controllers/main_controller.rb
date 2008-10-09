class MainController < ApplicationController
  skip_before_filter :check_auth

  def index
    redirect_to 'http://myousica.com/', :status => :moved_permanently
  end
end
