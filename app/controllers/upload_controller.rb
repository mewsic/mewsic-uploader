class UploadController < ApplicationController
  before_filter :check_valid_upload

  def index
    @output = random_output_file
    FileUtils.ln params[:upload].path, @output, :force => true
    
    respond_to do |format|
      format.xml { render :partial => 'upload', :status => :success }
    end
  end

  protected
    def check_valid_upload
      upload = params[:upload]
      unless upload && upload.respond_to?(:size) && upload.size > 0 && upload.content_type =~ /audio\/mpeg/
        render :text => upload.content_type, :status => :bad_request
      end
    end
end
