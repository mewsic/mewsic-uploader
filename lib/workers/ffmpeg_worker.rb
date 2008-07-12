require 'ffmpeg'
require 'waveform'

class FfmpegWorker < BackgrounDRb::MetaWorker
  set_worker_name :ffmpeg_worker
  pool_size 3
  attr_accessor :worker_status
  
  def create
    @worker_status = { }
    @status_mutex = Mutex.new
    register_status(@worker_status)
    Thread.abort_on_exception = true
  end

  def run(options)
    thread_pool.defer(options) do |options|
      # Initialization
      key = options[:key]
      input = options[:input]
      output = options[:output]
      length = 0

      update_status key, :idle, output, length

      processor = FFmpeg.new(input, output)

      # Encoding
      update_status key, :running, output, length
      processor.run

      while processor.running?
        update_status key, processor.status, output, length
        sleep 1
      end

      length = Mp3Info.new(output).length rescue 0

      # Waveform
      if processor.success?
        Adelao::Waveform.generate(output, :width => length * 10)
      end
      File.unlink input

      # Finished
      update_status key, processor.status, output, length
    end
  end
  
protected

  def update_status(key, status, output, length)
    @status_mutex.synchronize do
      @worker_status[key] = {:status => status, :output => output, :length => length}
    end
    register_status @worker_status
  end

end
