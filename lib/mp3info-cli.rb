class Mp3Info
  attr_reader :bitrate, :length, :mode, :channels
  def initialize(filename)
    raise ArgumentError, "non-existing file: #{filename}" unless File.exists? filename
    @bitrate, @length, @mode = `mp3info -r a -p "%r %S %o" #{filename}`.split(' ', 3)
    @bitrate = @bitrate.to_f
    @length = @length.to_i
    @channels = @mode =~ /stereo/ ? 2 : 1
  end
end
