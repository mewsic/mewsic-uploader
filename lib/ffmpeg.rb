require 'executable'

class FFmpeg < Executable
  def initialize(input, output)
    @input, @output = input, output
    @status = File.exists?(@input) ? :idle : :error
  end

  def to_cmd
    "ffmpeg -i #@input -ar #{MP3_FREQ} -ab #{MP3_RATE} -ac #{MP3_CHANNELS} #{MP3_OVERWRITE ? '-y' : ''} #@output"
  end
end
