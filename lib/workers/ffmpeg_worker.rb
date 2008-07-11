require 'ffmpeg'
require 'waveform'

class FfmpegWorker < BackgrounDRb::MetaWorker
  set_worker_name :ffmpeg_worker
  set_no_auto_load true
  
  def create(options)
    @input = options[:input]
    @output = options[:output]
    @length = 0

    @processor = FFmpeg.new(@input, @output)

    update_status
  end

  def run
    @processor.run

    while @processor.running?
      update_status
      sleep 1
    end

    @length = Mp3Info.open(@output).length.ceil rescue 0

    if @processor.success?
      Adelao::Waveform.generate(@output, :width => @length * 10)
    end

    File.unlink @input

    update_status
  end
  
protected

  def update_status
    register_status :status => @processor.status, :output => @output, :length => @length
  end

end
