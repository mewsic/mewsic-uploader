module Ffmpeg
  
  require "open3"
  
  class Ffmpeg  
    attr_accessor :status, :progress, :line
    
    def initialize()

      ### vabbe maniere forti:
#      state
#      0 = "idle"
#      1 = "running"
#      2 = "error"
#      3 = "finished"
      
      @status = 0
      @alive = true
      @flv = ""
      # parametri definiti nell'environment'
      @ar = AR
      @ab = AB
      @ac = AC
      @overwrite = OVERWRITE_EXISTING    
      
      @cmd = ""
      
    end
    
  
    def flv_to_mp3(flv)
        @flv = flv
        @status = 1
        
        @cmd = self.to_cmd("#{FLV_INPUT_DIR}#{@flv}.flv", "#{MP3_OUTPUT_DIR}#{@flv}.mp3")      
        # è inutile parsare l'output...tanto il progress non è in tempo reale
        # con la rescue sappiamo se va in errore e settiamo lo state
        #self.run(cmd)   
    end
    
    def alive?
      @alive
    end
    

    
    def run
      Thread.start() do
        begin 
          IO.popen(@cmd) do |pipe|
            # ok, stiamo andando avanti....
          end            
        
        
        @status = 3

        checkFile
        
        
        rescue => e
          @status = 2   
          @alive = false
          
        end

      end
    end
protected    
    def checkFile
      @alive = false
      @status = 2 unless File.exist?("#{MP3_OUTPUT_DIR}#{@flv}.mp3")
    end
    
    def to_cmd(input_name, output_name)
      return "ffmpeg -i #{input_name} -ar #{@ar} -ab #{@ab} -ac #{@ac} #{@overwrite} #{output_name}"
    end
  
  end
end