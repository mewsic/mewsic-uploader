module StrategyCommand

  class EffectCommand
    def commands(tracks)
      tracks.map do |t|  
        
        output_name = File.join(MP3_OUTPUT_DIR, 'effect', t.filename)
        
        command = "sox -v #{t.volume} #{File.join(MP3_OUTPUT_DIR, t.filename)} #{output_name} pan #{t.balance} pad #{t.time_shift}"
        command << " repeat #{t.repeat_count} " if t.loop.to_i == 1
        
        {:command => command, :output => output_name}
      end
    end    
  end
  
  
  class MixerCommand
    def commands(tracks, output_name)
      
      command = "sox -m " << tracks.map do |t|
        File.join(MP3_OUTPUT_DIR, 'effect', t.filename)
      end.join(' ')

      output_name = File.join(MP3_OUTPUT_DIR, "#{output_name}.mp3")
      command << ' ' << output_name
      
      return [{:command => command, :output => output_name}]
    end
  end
  
  class CommandFactory
    def self.get_strategy(type)
      {:effect => EffectCommand, :mixer => MixerCommand}[type].new
    end
  end
  
end
