module StrategyCommand
  
  
  # "the ruby world would firmly vote for skipping the Command base class" # Design Patterns in Ruby
  # class Command
  
  
  class EffectCommand
    
    def commands(tracks )
      commands_a = []
      tracks.each do
        |t|  
        
        output_name = "#{MP3_OUTPUT_DIR}effect_#{t.filename}"
        
        command = "sox -v #{t.volume} #{File.join(MP3_OUTPUT_DIR, t.filename)} #{output_name}  pan #{t.balance} pad #{t.time_shift} "
        command << " repeat #{t.repeat_count} " if t.loop == "1"
        
        # uff, non so come chiarmarlo
        command_container = {:command => command, :output => output_name}
        
        
        commands_a << command_container
      end
      return commands_a
      
    end    
  
  end
  
  
  class MixerCommand
    def commands(tracks, output_name)
      
      output_name = "#{MP3_OUTPUT_DIR}#{output_name}.mp3 "
      
      command = "sox -m "
      tracks.each do
        |t|
          command << " #{MP3_OUTPUT_DIR}effect_#{t.filename} "   
      end
      command << output_name
      
      command_container = {:command => command, :output => output_name}
      
      return Array.new(1){command_container}
    end
  end
  
  class CommandFactory
    @strategies = {:effect => EffectCommand, :mixer => MixerCommand}
    
    def self.get_strategy(type)
      return @strategies[type].new
    end
  end
  
end