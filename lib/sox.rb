require 'executable'
require 'stdoutputter'

class SoxAnalyzer < StdOutputter

  def initialize(input)
    @input = input
  end

  def to_cmd
    "sox -t mp3 %s -n stat -v" % @input
  end

  def optimum_volume
    @output.to_f * 90 / 100
  end

end

class SoxNormalizer < Executable

  def initialize(input, output, volume)
    @input, @output, @volume = input, output, volume
    @status = :idle
  end

  def to_cmd
    "sox -v %f -t mp3 %s -t wav %s" % [@volume, @input, @output]
  end

end

class SoxEffect < Executable

  def initialize(track, output)
    @track, @output = track, output
    @status = File.exists?(track.filename) ? :idle : :error
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
    @status = tracklist.all? { |track| File.exists? track.file.path } ? :idle : :error
  end

  def to_cmd
    #"sox -m " << @tracklist.map { |track| "-t #{track.format} -v 1.0 #{track.file.path}" }.join(' ') << " -t mp3 #@output"
    "sox -m " << @tracklist.map { |track| "-t #{track.format} #{track.file.path}" }.join(' ') << " -t mp3 #@output"
  end

  class Track < Struct.new(:file, :format)
  end

end
