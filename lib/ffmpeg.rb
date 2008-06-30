class FFmpeg
  attr_reader :status, :output

  def initialize(input)
    @input = File.join(FLV_INPUT_DIR, "#{input}.flv")
    @output = File.join(MP3_OUTPUT_DIR, "#{MD5.md5(input)}.mp3")

    @status = File.exists?(@input) ? :idle : :error
  end

  def to_cmd
    "ffmpeg -i #@input -ar #{AR} -ab #{AB} -ac #{AC} #{OVERWRITE_EXISTING} #@output"
  end

  def alive?
    @status == :running
  end

  def success?
    @status == :finished
  end

  def output_name
    File.basename @output
  end

  def run
    return unless @status == :idle
    @status = :running

    Thread.new do
      system self.to_cmd
      @status = File.exist?(@output) ? :finished : :error
    end
  end

end
