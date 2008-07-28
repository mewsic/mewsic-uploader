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

        format = 'mp3'
        if input =~ /\.flv$/
          # Convert it to wave
          tempfile = Tempfile.new 'wavepass'
          process = Wavepass.new(input, tempfile.path).run
          raise EncodingError, 'failed to convert flv to wave' unless process.success?
          File.unlink(input)
          input = tempfile.path
          format = 'wav'
        end

        # Analysis
        process = SoxAnalyzer.new(input, format).run
        raise EncodingError, 'failed to analyze wave' unless process.success?
        raise EncodingError if process.optimum_volume.zero?

        # Normalization
        tempfile = Tempfile.new 'normalizer'
        process = SoxNormalizer.new(input, tempfile.path, process.optimum_volume).run
        raise EncodingError, 'failed to normalize' unless process.success?
        File.unlink(input)
        input = tempfile.path

        # Encoding
        process = FFmpeg.new(input, output).run
        raise EncodingError, 'failed to encode' unless process.success?

        # Length
        length = Mp3Info.new(output).length rescue 0 # XXX

        # Waveform
        Adelao::Waveform.generate(input, output.sub('.mp3', '.png'), :width => length * 10)

        # Finished
        update_status key, :finished, output, length

      rescue EncodingError
        puts "exception: #{$!}"
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
