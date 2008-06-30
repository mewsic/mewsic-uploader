require 'tempfile'

module Adelao
  class Waveform
    DefaultOptions = {
      :linecolor => '000000',
      :backgroundcolor => 'ffffff',
      :zerocolor => '808080',
      :type => 'png',
      :padding => 0,
      :width => 800,
      :height => 50
    }

    def self.generate(input, options = {})
      output = options.delete(:output) || input.sub(/\.mp3$/, '.png')
      options = DefaultOptions.merge(options)

      options.assert_valid_keys :linecolor, :backgroundcolor, :zerocolor, :type, :padding, :width, :height, :verbose
      options_string = options.map { |k,v| " --#{k}=#{v}" }

      temp = Tempfile.open('waveform')

      Process.wait(fork { exec("madplay -o wave:#{temp.path} #{input}") })
      Process.wait(fork { exec("wav2png --input=#{temp.path} --output=#{output} #{options_string}") })
      temp.close!
    end
  end
end

#Adelao::Waveform.generate track.path, :linecolor => '000000', :backgroundcolor => 'ffffff',
#  :zerocolor => '808080', :type => 'png', :padding => 0, :width => 800, :height => 50
