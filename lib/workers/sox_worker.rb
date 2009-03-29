require 'net/http'
require 'tracklist'
require 'sox'
require 'ffmpeg'
require 'services'

class SoxError < StandardError
end

class SoxWorker < BackgrounDRb::MetaWorker
  set_worker_name :sox_worker
  pool_size 3

  def create(args = nil)
  end

  def run(options)
    thread_pool.defer(:mix_tracklist, options)
  end

private
  def mix_tracklist(options)
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
        update_mixable :path => SONG_SERVICE, :filename => File.basename(output), 
          :length => length, :song_id => options[:song_id], :user_id => options[:user_id]
      end

      update_status key, :finished, output, length

    rescue SoxError, ServiceError
      puts "exception: #{$!}"
      update_status key, :error, output, length

    ensure
      # Cleanup
      tracks.each { |track| track.file.is_a?(Tempfile) ? track.file.close! : track.file.close }
      GC.start
    end
  end
  
protected
  def update_status(key, status, output, length)
    cache[key] = {:status => status, :output => output, :length => length, :ts => Time.now}
  end

end
