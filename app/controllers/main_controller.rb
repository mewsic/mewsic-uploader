class MainController < ApplicationController
  def index
    redirect_to 'http://myousica.com/', :status => :moved_permanently
  end
end
