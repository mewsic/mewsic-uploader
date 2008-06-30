require 'executable'

class SoxEffect < Executable

  def initialize(track, output)
    @track, @output = track, output
    @status = File.exists?(track.filename) ? :idle : :error
  end

  def self.needed?(track)
    track.volume < 1.0 || track.balance != 0.0
  end

  def to_cmd
    "sox %s #{@track.filename} #@output %s" % [
      ("-v #{@track.volume}" if @track.volume < 1.0),
      ("pan #{@track.balance}" if @track.balance != 0.0)
    ]
  end

end

class SoxMixer < Executable

  def initialize(tracklist, output)
    @tracklist, @output = tracklist, output
    @status = tracklist.all? { |t| File.exists? t.filename } ? :idle : :error
  end

  def to_cmd
    "sox -m " << @tracklist.join(' ') << ' ' << @output
  end

end
