require "#{RAILS_ROOT}/lib/sox"
require "#{RAILS_ROOT}/lib/clear"

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
    
    # finiti tutti i passaggi di encoding 
    # 1. mando un clear storage
    clear
    
    # 2. controllo effettivamente che il file esista
    update_status(:error) unless check_output(arg_commands)
  end
  
protected
  def update_status(status)
    register_status(:key => @worker_key, :status => status)
  end
  
  def clear
    Clear.all(MP3_OUTPUT_DIR, "effect")
  end
  
  def check_output(commands)
    # qui sappiamo che il file che ci interessa è l'ultimo
    File.exists?(commands.last[:output])
  end
end
