require "#{RAILS_ROOT}/lib/ffmpeg"

class FfmpegWorker < BackgrounDRb::MetaWorker

  include Ffmpeg
  set_worker_name :ffmpeg_worker
  
  def create(args = nil)
    
    @verbalized_status = ["idle", "running", "error", "finished"]
    if args
      @worker_key = args[:key]
    end    
    
    @sleep_time = 2
  end
  
  def start(filename)
    # avvio il tutto
    ffmpeg_process = Ffmpeg.new
    ffmpeg_process.flv_to_mp3(filename)
    
    update_status(ffmpeg_process.status)
    ffmpeg_process.run

    while ffmpeg_process.alive?
      
     update_status(ffmpeg_process.status)
      
      sleep @sleep_time
    end
    
    update_status(ffmpeg_process.status)
   
    
  end
  
protected
  def update_status(status)
    progress_info = {:key => @worker_key,     
        :status => @verbalized_status[status]
      }
    register_status(progress_info)
    
  end

    
end

