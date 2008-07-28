require 'executable'

class FFmpeg < Executable
  def initialize(input, output)
    @input, @output = input, output
    @format = 'mp3'
    @quality = "-ab #{MP3_RATE * 1024}"
    @quality << " -aq #{MP3_QUALITY}" if MP3_VBR
    @overwrite = MP3_OVERWRITE ? '-y' : ''

    error unless File.exists?(@input)
  end

  def to_cmd
    "ffmpeg -i #@input -ar #{MP3_FREQ} -ac #{MP3_CHANNELS} #@quality #@overwrite -f #@format #@output"
  end
end

class Wavepass < FFmpeg
  def initialize(input, output)
    super(input, output)
    @format = 'wav'
    @overwrite = '-y'
  end
end
