require 'ffmpeg'
require 'waveform'

class FfmpegWorker < BackgrounDRb::MetaWorker
  set_worker_name :ffmpeg_worker
  set_no_auto_load true
  
  def create(args = nil)
    @worker_key = args[:key] if args
  end
  
  def run(filename)
    @ffmpeg = FFmpeg.new(filename)
    @ffmpeg.run

    update_status

    sleep(2) while @ffmpeg.alive?

    if @ffmpeg.success?
      Adelao::Waveform.generate(@ffmpeg.output)
    end

    update_status
  end
  
protected

  def update_status
    register_status :key => @worker_key, :status => @ffmpeg.status, :output => @ffmpeg.output_name
  end

end
