module Sox

  class SoxCommandList
    attr_accessor :status
    
    def initialize
      
      @command_containers = []
      @status = :idle
      @alive = true
      @sleep_time = 2
      @output_name = ""
    end
    
    def commands(arg_commands, output_name)
      @command_containers = arg_commands
      @output_name = output_name
    end
    
    def run
      @status = :running
      exit_with_error if @command_containers.nil?
      
      # qui mando un comando alla volta...
      @command_containers.each do
        |command_container|
        
        puts command_container.inspect
        
        
        # creo l'oggetto command vero e proprio
        current_command = SoxCommand.new
        current_command.set_output_for_check command_container[:output]
        current_command.execute(command_container[:command])
        
        # anche qui resto sospesa in attesa....
        while current_command.alive?
          sleep @sleep_time
        end
        
        
        #check_file(command_container[:output])
        
        # controllo che il comando non sia andato in errore
        #if current_command.status == :error
        #  exit_with_error
        #  break
        #end
                
      end
    end
    
    
    def alive?
      @alive  
    end
     
protected
    def exit_with_error
      
      puts "EXIT WITH ERROR"
      @status = :error
      @alive = false
    end
    
    def check_file(filename)
      # il check file è una procedura un po' delicata
      # mantenendo lo stesso contesto è sempre a false
      # anche se il file esiste, per cui aggiungo un
      # un nuovo worker, così sono sicura del risultato
      worker_key = "checker_#{filename}"  
      worker_args = {:worker_key => worker_key, :filename => filename}
      MiddleMan.new_worker(:worker => :checker_worker, :job_key => worker_key, :data => worker_args) 
      MiddleMan.worker(:checker_worker, worker_key).start

      sleep 5    
      
      exit_with_error unless ask_exist?(worker_key)
    #  puts "CHECK FILE #{filename}"
    #  puts "# #{File.file?(filename)}"
      
      
    end
    
    def ask_exist?(worker_key)
      
      
      puts "ASK EXIST"
      
      worker_info = MiddleMan.worker(:checker_worker, worker_key ).ask_status
      
      puts "WORKER_INFO"
      puts worker_info.inspect
      
      worker_info[:status]
    end

  end # end soxCommandList class
  
  class SoxCommand
    
    attr_accessor :status
    
    def initialize
      @status = :idle
      @alive = true
      @output = nil      
    end
    
    
    def execute(cmd)
      # FINALMENTE!!!!
      
        puts "1. MANDIAMO IL COMANDO #{cmd}"
      
        Thread.start() do
          @status = :running
          begin 
            IO.popen(cmd) do |pipe|
              # ok, stiamo andando avanti....
            end            
          
          @status = :finished
          @alive = false
          #check_file 
          
          puts "2.  il comando è finito " 
          puts "    il nostro status è #{@status}"
          
          rescue => e
            @status = :error
            @alive = false
            
            puts "2. siamo entrati in rescue #{e.inspect} " 
          end
        end
    end
    
    def set_output_for_check(output_name)
      @output = output_name
    end
    
    def alive?
      @alive
    end
  

    
  end
  
end