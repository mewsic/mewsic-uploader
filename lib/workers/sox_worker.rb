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
        files = []

        update_status key, :idle, output, length

        tracklist.each do |track|
          if SoxEffect.needed?(track)
            tempfile = Tempfile.new 'effect'

            effect = SoxEffect.new(track, tempfile.path).run
            while effect.running?
              update_status key, :running, output, length
              sleep 1
            end

            raise SoxError, "error while processing #{track.filename}" unless effect.success?

            files << tempfile
          else
            files << File.open(track.filename, 'r')
          end
        end

        mixer = SoxMixer.new(files.map(&:path), output).run
        while mixer.running?
          update_status key, :running, output, length
          sleep 1
        end

        raise SoxError, "error while mixing to #{output}" unless mixer.success?

        length = Mp3Info.new(output).length rescue 0

        Adelao::Waveform.generate(output, :width => length * 10)

        update_status key, :finished, output, length

      rescue SoxError
        puts "exception: #{$!}"
        update_status key, :error, output, length

      ensure
        files.each { |f| f.is_a?(Tempfile) ? f.close! : f.close }
      end
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
