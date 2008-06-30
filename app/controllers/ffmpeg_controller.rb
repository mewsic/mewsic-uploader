class FfmpegController < ApplicationController
  def index
    @worker_key = random_md5
    input = input_file(params[:filename] + '.flv')

    unless File.exists? input
      render :text => 'file not found', :status => :bad_request and return
    end

    MiddleMan.new_worker :worker => :ffmpeg_worker, :job_key => @worker_key,
                         :data => {:input => input, :output => random_output_file}

    MiddleMan.worker(:ffmpeg_worker, @worker_key).run
    
    render_worker_status
  end

  def status
    @worker_key = params[:worker]

    if [:finished, :error].include? worker_status[:status]
      MiddleMan.delete_worker(:worker => :ffmpeg_worker, :job_key => @worker_key)
    end 

    render_worker_status
  end

  private

    def worker_status
      MiddleMan.worker(:ffmpeg_worker, @worker_key).ask_status || Hash.new('')
    end

end
