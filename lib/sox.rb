require 'executable'
require 'stdoutputter'

class SoxAnalyzer < StdOutputter

  def initialize(input, format = 'mp3')
    @input = input
    @format = format
    error unless File.exists?(input)
  end

  def to_cmd
    "sox -t %s %s -n stat -v" % [@format, @input]
  end

  def optimum_volume
    @output.to_f * 90 / 100
  end

end

class SoxNormalizer < Executable

  def initialize(input, output, volume, format = 'mp3')
    @input, @output, @volume, @format = input, output, volume, format
    error unless File.exists?(input)
  end

  def to_cmd
    "sox -v %f -t %s %s -t wav %s" % [@volume, @format, @input, @output]
  end

end

class SoxEffect < Executable

  def initialize(track, output)
    @track, @output = track, output
    error unless File.exists?(track.filename)
  end

  def self.needed?(track)
    track.volume != 1.0 || track.balance != 0.0
  end

  def to_cmd
    "sox %s -t mp3 #{@track.filename} -t wav #@output %s" % [
      ("-v #{@track.volume}" if @track.volume != 1.0),
      ("pan #{@track.balance}" if @track.balance != 0.0)
    ]
  end

end

class SoxMixer < Executable

  def initialize(tracklist, output)
    @tracklist, @output = tracklist, output
    error unless tracklist.all? { |track| File.exists? track.file.path }
  end

  def to_cmd
    mix = '-m' if @tracklist.size > 1
    vol = "-v 1.0"
    "sox #{mix} " << @tracklist.map { |track| "-t #{track.format} #{vol} #{track.file.path}" }.join(' ') << " -t wav #@output"
  end

  class Track < Struct.new(:file, :format)
  end

end
