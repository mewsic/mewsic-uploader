require 'ffmpeg'
require 'waveform'

class EncodingError < StandardError
end

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
      begin
        # Initialization
        key = options[:key]
        input = options[:input]
        output = options[:output]
        length = 0

        update_status key, :running, output, length

        # Analysis
        process = SoxAnalyzer.new(input).run
        sleep(1) while process.running?
        raise EncodingError unless process.success?
        raise EncodingError if process.optimum_volume.zero?

        # Normalization
        if process.optimum_volume != 1.0
          tempfile = Tempfile.new 'normalizer'

          process = SoxNormalizer.new(input, tempfile.path, process.optimum_volume).run
          sleep(1) while process.running?
          raise EncodingError unless process.success?

          File.unlink(input)
          input = tempfile.path
        end

        # Encoding
        process = FFmpeg.new(input, output).run
        sleep(1) while process.running?
        raise EncodingError unless process.success?

        # Waveform
        length = Mp3Info.new(output).length rescue 0 # XXX
        Adelao::Waveform.generate(output, :width => length * 10)

        # Finished
        update_status key, :finished, output, length

      rescue EncodingError
        update_status key, :error, output, length

      ensure
        # Cleanup
        File.unlink input
        GC.start
      end
    end
  end
  
protected

  def update_status(key, status, output, length)
    @status_mutex.synchronize do
      @worker_status[key] = {:status => status, :output => output, :length => length, :ts => Time.now}
    end
    register_status @worker_status
  end

end
