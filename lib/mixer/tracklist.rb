require 'rexml/document'
require "#{RAILS_ROOT}/lib/mixer/track"
require "#{RAILS_ROOT}/lib/mixer/strategy_command"



  class Tracklist
    
    include REXML
    include StrategyCommand
    
    attr_accessor :tracks, :commands, :state
    
    
    def initialize(tracks, output_name)      
      @output_name = output_name
      @tracks   = []
      @commands = []  
      @state = :idle
      
      run(tracks)
      
    end
    
    def run(tracks)
      @state = :running
      parse_tracks(tracks)
      
      # parsate tutte le track creo la lista dei comandi...
      create_commands_list 
      
    end
    
    def add_track(track)
      tmp_track = Track.new track
      
      
      # vado ad aggiungere la track a tracks ammenochè non abbia un errore...cioè non è indicato il file da
      # convertire per cui skippo
      @tracks << tmp_track unless tmp_track.state == :error
      
    end
    
    def running?
      return_value = false
      return_value = true if self.state == :running
    end
    
  protected
    def create_commands_list
      # qui mi rifaccio allo strategycommand per cui
      # 1. creo la lista dei command effects:
      command_effect_strategy = CommandFactory.get_strategy(:effect)
      @commands = command_effect_strategy.commands(@tracks)
      
      command_mixer_strategy = CommandFactory.get_strategy(:mixer)
      @commands.concat command_mixer_strategy.commands(@tracks, @output_name)
      
            
      # ha finito tutto
      @state = :ready
      
    end

    def parse_tracks(tracks)
      doc = Document.new tracks
      
      # ciclo sugli elementi "track"
      doc.root.each_element do
        |e| 
        add_track e
      end
    end
    
    
  end  


  
