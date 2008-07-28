# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'net/http'

class ApplicationController < ActionController::Base
  # before_filter :check_auth

  def input_file(name)
    File.join(FLV_INPUT_DIR, name)
  end

  def output_file(name)
    File.join(MP3_OUTPUT_DIR, name)
  end

  def random_output_file(ext = 'mp3')
    loop do
      path = File.join(MP3_OUTPUT_DIR, random_md5 << '.' << ext)
      return path unless File.exists? path
    end
  end

  def random_md5
    MD5.md5(rand.to_s).to_s
  end

  def render_worker_status
    respond_to do |format|
      format.xml { render :partial => 'shared/worker', :object => worker_status, :status => :ok }
    end
  end

  def check_auth
    # Trust cookie sessions
    if session[:user].is_a? Numeric
      return
    end

    # When uploading .. heck! Authorize to the main server
    unless params[:id] && params[:token] && params[:id].to_i > 0 && params[:token] =~ /^\w+$/
      redirect_to '/' and return
    end

    url = URI.parse "#{AUTH_SERVICE}/#{params[:id]}?token=#{params[:token]}"
    unless Net::HTTP.start(url.host, url.port) { |http| http.get(url.path) }.is_a?(Net::HTTPSuccess)
      redirect_to '/' and return
    end

  end

end
