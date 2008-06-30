class UploadController < ApplicationController
  before_filter :check_valid_upload

  def index
    @output = random_output_file
    File.open(@output, 'w+') do |file|
      file.write params[:upload].read
    end
    
    respond_to do |format|
      format.xml { render :partial => 'upload', :status => :success }
    end
  end

  protected
    def check_valid_upload
      unless params[:upload] && params[:upload].respond_to?(:size) && params[:upload].size > 0
        render :nothing => true, :status => :bad_request
      end
    end
end
