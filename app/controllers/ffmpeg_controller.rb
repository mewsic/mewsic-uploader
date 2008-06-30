class FfmpegController < ApplicationController
  def index
    @worker_key = random_md5
    input = input_file(params[:filename] + '.flv')

    unless File.exists? input
      render :nothing => true, :status => :bad_request and return
    end

    MiddleMan.new_worker :worker => :ffmpeg_worker, :job_key => @worker_key,
                         :data => {:input => input, :output => random_output_file}

    MiddleMan.worker(:ffmpeg_worker, @worker_key).run
    
    respond_to do |format|
      format.xml { render :partial => 'worker', :object => worker_status }
    end
  end

  def status
    @worker_key = params[:worker]

    if worker_status[:status] == :finished
      MiddleMan.delete_worker(:worker => :ffmpeg_worker, :job_key => @worker_key)
    end 
    
    respond_to do |format|
      format.xml { render :partial => 'worker', :object => worker_status }
    end
  end

  private
    def worker_status
      MiddleMan.worker(:ffmpeg_worker, @worker_key).ask_status || Hash.new('')
    end

end
