class UploadController < ApplicationController
  before_filter :check_valid_upload

  def index
    @output = random_output_file
    FileUtils.cp params[:upload].path, @output
    @mp3info = Mp3Info.open @output
    MiddleMan.worker(:waveform_worker).generate(@output)
    
    respond_to do |format|
      format.xml { render :partial => 'upload', :status => :success }
    end
  end

  protected
    def check_valid_upload
      upload = params[:upload]
      unless upload && upload.respond_to?(:size) && upload.size > 0 && upload.content_type =~ /^audio\/mpeg$/
        render :text => 'invalid upload', :status => :bad_request
      end
    end
end
