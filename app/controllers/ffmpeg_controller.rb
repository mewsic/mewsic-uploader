class FfmpegController < ApplicationController
  def index
    @worker_key = random_md5
    input = input_file(params[:filename] + '.flv')

    unless File.exists? input
      render :text => 'file not found', :status => :bad_request and return
    end

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

  private
    def worker_status
      MiddleMan.worker(:ffmpeg_worker).ask_status[@worker_key] || Hash.new('')
    end

end
