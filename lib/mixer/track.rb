require 'rexml/document'

  
  class Track
        
    include REXML

    
    attr_accessor :state
    attr_accessor :volume, :loop, :balance, :time_shift, :filename, :length, :repeat_count
    
    
    
    def initialize(track)
      @state = :idle
      @volume = 0.5
      @loop = 0
      @balance = 0
      @time_shift = 0        
      @filename = ""
      @length = 0
      @repeat_count = 0
      
      parse_track(track)
    end
    
    

  protected
    def parse_track(track)
          # è chiaro che se non abbiamo il nome del file non possiamo fare nulla
          
          unless track.elements["filename"].nil?
            @volume = track.elements["volume"].text unless track.elements["volume"].nil?
            @loop = track.elements["loop"].text  unless track.elements["loop"].nil?
            @repeat_count = track.elements["repeat_count"].text  unless track.elements["repeat_count"].nil?
            @balance = track.elements["balance"].text  unless track.elements["balance"].nil?       
            @time_shift = track.elements["time_shift"].text  unless track.elements["time_shift"].nil?       
            @filename = track.elements["filename"].text.sub(/^\/audio/, '')
            @length = track.elements["length"].text  unless track.elements["length"].nil?
            # vabbè un po' zozzo ma per sicurezza controllo ancora
            @state = :error if @filename ==""
          else
            @state  = :error
          end
             
          
             end
  end
  
