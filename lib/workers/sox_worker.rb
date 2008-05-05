require "#{RAILS_ROOT}/lib/sox"

class SoxWorker < BackgrounDRb::MetaWorker
  include Sox
  
  set_worker_name :sox_worker
  def create(args = nil)
    
    if args
      @worker_key = args[:key]
      @output_name = args[:output_name]
    end    
    
    @sleep_time = 2
  end
  
  
  def start(arg_commands)
    
    
    puts "WORKER START"
    
    # avvio il tutto il commandlist esegue un comando alla volta
    sox_process = SoxCommandList.new
    sox_process.commands(arg_commands, @output_name)
    
    update_status(sox_process.status)
    sox_process.run
    
    while sox_process.alive?
          
     update_status(sox_process.status)
      
      sleep @sleep_time
    end
    
    
    
    
    update_status(sox_process.status)
    
  end
  
protected
  def update_status(status)
    progress_info = {:key => @worker_key,     
        :status => status
      }
    register_status(progress_info)
    
  end


  
  
end

