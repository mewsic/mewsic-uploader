class UploadController < ApplicationController
  before_filter :check_valid_upload, :only => :index
  session :cookie_only => false

  def index
    @worker_key = random_md5

    # XXX maybe this file copy can be avoided, using directly the temporary 
    # upload file? better safe than sorry for now.
    #
    # -vjt
    input = input_file(random_md5) << '.mp3'
    FileUtils.cp params[:Filedata].path, input

    MiddleMan.ask_work :worker => :ffmpeg_worker, :worker_method => :run,
                       :data => {
                         :key => @worker_key,
                         :input => input,
                         :output => random_output_file
                       }

    render_worker_status
  end

  def status
    @worker_key = params[:worker]
    render_worker_status
  end

  protected
    def check_valid_upload
      upload = params[:Filedata]
      unless upload && upload.respond_to?(:size) && upload.size > 0 #&& upload.content_type =~ /^audio\/mpeg$/
        render :text => "invalid upload #{upload.content_type rescue nil} #{upload.size rescue nil}", :status => 400
      end
    end

  private

    def worker_status
      MiddleMan.worker(:ffmpeg_worker).ask_status[@worker_key] || Hash.new('')
    end

end
