module Sox

  class SoxCommandList
    attr_reader :status, :alive
    alias_method :alive?, :alive
    
    def initialize
      
      @commands = []
      @status = :idle
      @alive = true
      @sleep_time = 2
      @output_name = ""
    end
    
    def commands(arg_commands, output_name)
      @commands = arg_commands
      @output_name = output_name
    end
    
    def run
      @status = :running

      if @commands.nil? || @commands.empty?
        @status = :error
        @alive = false
        return
      end
      
      # qui mando un comando alla volta...
      @commands.each do |cmd|
        
        # creo l'oggetto command vero e proprio
        current_command = SoxCommand.new
        current_command.execute(cmd[:command])
        
        # anche qui resto sospesa in attesa....
        while current_command.alive?
          sleep @sleep_time
        end
        
        # controllo che il comando non sia andato in errore
        if current_command.status == :error
          @status = :error
          @alive = false
          return
        end
      end

      puts "FINISHED!"
      @status = :finished
      @alive = false
    end
     
  end # end soxCommandList class
  
  class SoxCommand
    
    attr_reader :status, :alive
    alias_method :alive?, :alive
    
    def initialize
      @status = :idle
      @alive = true
    end
    
    
    def execute(cmd)
      puts "running #{cmd}"

      Thread.start() do
        @status = :running
        begin 
          IO.popen(cmd) do |pipe|
            # ok, stiamo andando avanti....
          end            

          @status = :finished
          @alive = false

          puts "completed #{cmd}"

        rescue Exception => e
          @status = :error
          @alive = false

          puts "error #{cmd}: #{e.inspect}"
        end
      end
    end
  end

end
