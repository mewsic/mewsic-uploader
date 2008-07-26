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
    FlashMaxWidth = 2879

    def self.generate(input, output, options = {})
      options = DefaultOptions.merge(options)

      options.assert_valid_keys :linecolor, :backgroundcolor, :zerocolor, :type, :padding, :width, :height, :verbose

      options[:width] = FlashMaxWidth if options[:width] > FlashMaxWidth # XXX flash hack
      options_string = options.map { |k,v| " --#{k}=#{v}" }

      Process.wait(fork { exec("wav2png --input=#{input} --output=#{output} #{options_string}") })
    end
  end
end
