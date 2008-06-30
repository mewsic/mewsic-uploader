class FfmpegController < ApplicationController
  def index
    @worker_key = MD5.md5(rand.to_s).to_s

    MiddleMan.new_worker(:worker => :ffmpeg_worker, :job_key => @worker_key, :data => {:worker_key => @worker_key}) 
    MiddleMan.worker(:ffmpeg_worker, @worker_key).run(params[:filename])
    
    respond_to do |format|
      format.xml { render :partial => 'worker', :object => worker }
    end
  end

  def status
    @worker_key = params[:worker]

    if worker[:status] == :finished
      MiddleMan.delete_worker(:worker => :ffmpeg_worker, :job_key => @worker_key)
    end 
    
    respond_to do |format|
      format.xml { render :partial => 'worker', :object => worker }
    end
  end

  private
    def worker
      @worker ||= MiddleMan.worker(:ffmpeg_worker, @worker_key).ask_status || {:status => :idle}
    end

end
