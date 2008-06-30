class FFmpeg
  attr_reader :status

  def initialize(input, output)
    @input, @output = input, output
    @status = File.exists?(@input) ? :idle : :error
  end

  def to_cmd
    "ffmpeg -i #@input -ar #{MP3_FREQ} -ab #{MP3_RATE} -ac #{MP3_CHANNELS} #{MP3_OVERWRITE ? '-y' : ''} #@output"
  end

  def run
    return unless @status == :idle

    @status = :running
    @pid = fork { exec(self.to_cmd) }
  end

  def alive?
    if @pid && Process.wait(@pid, Process::WNOHANG)
      @pid = nil
      @status = File.exist?(@output) ? :finished : :error
    end

    @status == :running
  end

  def success?
    @status == :finished
  end

end
