require 'net/http'
require 'tracklist'
require 'sox'

class SoxError < StandardError
end

class SoxWorker < BackgrounDRb::MetaWorker
  set_worker_name :sox_worker
  pool_size 3
  attr_accessor :worker_status

  def create(args)
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
        output = options[:output]
        tracklist = options[:tracks]
        length = 0

        update_status key, :running, output, length

        # Apply effects
        tracks = []
        tracklist.each do |track|
          next if track.volume.zero?

          if SoxEffect.needed?(track)
            # If an effect is requested, execute it
            file = Tempfile.new 'effect'

            process = SoxEffect.new(track, file.path).run
            raise SoxError, "error while processing #{track.filename}" unless process.success?

            tracks << SoxMixer::Track.new(file, 'wav')
          else
            # Else, use the original file
            file = File.open track.filename, 'r'

            tracks << SoxMixer::Track.new(file, 'mp3')
          end
        end

        raise SoxError, "empty tracklist" if tracks.empty?

        # Mix the tracklist
        temp = Tempfile.new 'mixer'
        process = SoxMixer.new(tracks, temp.path).run
        raise SoxError, "error while mixing to temporary file" unless process.success?

        # Encoding
        process = FFmpeg.new(temp.path, output).run
        raise SoxError, "error while encoding to #{File.basename(output)}" unless process.success?

        # Length
        length = Mp3Info.new(output).length rescue 0 # XXX

        # Waveform
        Adelao::Waveform.generate(temp.path, output.sub('.mp3', '.png'), :width => length * 10)

        temp.close!

        if options[:song_id]
          filename = File.basename(output)
          url = URI.parse "#{SONG_SERVICE}/#{options[:user_id]}?song_id=#{options[:song_id]}&filename=#{filename}&length=#{length}"
          unless Net::HTTP.start(url.host, url.port) { |http| http.get(url.path + '?' + url.query) }.is_a?(Net::HTTPSuccess)
            raise SoxError, "error while updating song filename; #{$!}"
          end
        end

        update_status key, :finished, output, length

      rescue SoxError
        puts "exception: #{$!}"
        update_status key, :error, output, length

      ensure
        # Cleanup
        tracks.each { |track| track.file.is_a?(Tempfile) ? track.file.close! : track.file.close }
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
