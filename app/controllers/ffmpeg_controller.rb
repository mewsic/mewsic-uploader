class FfmpegController < ApplicationController
  def index
    unless params[:filename] =~ /[\w\d\.]+/
      render :text => 'invalid file name', :status => :bad_request and return
    end

    input = input_file(params[:filename] + '.flv')

    unless File.exists? input
      render :text => 'file not found', :status => :bad_request and return
    end

    @worker_key = random_md5

    MiddleMan.worker(:ffmpeg_worker).async_run(
      :arg => {
        :key => @worker_key,
        :input => input,
        :output => random_output_file
      })

    render_worker_status
  end

  def status
    @worker_key = params[:worker]
    render_worker_status
  end

  private
    def worker_status
      MiddleMan.worker(:ffmpeg_worker).ask_result(@worker_key) || Hash.new('')
    end

end
