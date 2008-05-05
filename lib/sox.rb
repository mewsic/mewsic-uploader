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
        
        # controllo che il comando non sia andato in errore
        if current_command.status == :error
          exit_with_error
          break
        end
                
      end
      
      
      puts "finito il tutto ---- #{output_name}"
      
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
          
          check_file 
          
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
  
  protected
    def check_file
      @alive = false
      @status = :error unless File.exist?(@output)
    end
    
  end
  
end