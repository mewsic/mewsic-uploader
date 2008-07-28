require 'executable'

class FFmpeg < Executable
  def initialize(input, output)
    @input, @output = input, output
    error unless File.exists?(@input)
  end

  def to_cmd
    quality = "-ab #{MP3_RATE * 1024}"
    quality << " -aq #{MP3_QUALITY}" if MP3_VBR
    overwrite = MP3_OVERWRITE ? '-y' : ''

    "ffmpeg -i #@input -ar #{MP3_FREQ} -ac #{MP3_CHANNELS} #{quality} #{overwrite} #@output"
  end
end

class Wavepass < Executable
  def initialize(input, output)
    @input, @output = input, output
    error unless File.exists?(@input)
  end

  def to_cmd
    "ffmpeg -i #@input -f wav -y #@output"
  end
end
