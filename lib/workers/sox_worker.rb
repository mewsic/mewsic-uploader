require 'tracklist'
require 'sox'

class SoxError < StandardError
end

class SoxWorker < BackgrounDRb::MetaWorker
  set_worker_name :sox_worker
  set_no_auto_load true

  def create(args)
    @tracklist = args[:tracks]
    @output = args[:output]
    @length = 0

    update_status(:idle)
  end

  def run
    files = []
    @tracklist.each do |track|
      if SoxEffect.needed?(track)
        tempfile = Tempfile.new 'effect'

        effect = SoxEffect.new(track, tempfile.path).run
        while effect.running?
          update_status(:running)
          sleep 1
        end

        raise SoxError, "error while processing #{track.filename}" unless effect.success?

        files << tempfile
      else
        files << File.open(track.filename, 'r')
      end
    end

    mixer = SoxMixer.new(files.map(&:path), @output).run
    while mixer.running?
      update_status(:running)
      sleep 1
    end

    raise SoxError, "error while mixing to #@output" unless mixer.success?

    @length = Mp3Info.new(@output).length rescue 0

    Adelao::Waveform.generate(@output, :width => @length * 10)

    update_status(:finished)

  rescue SoxError
    puts "exception: #{$!}"
    update_status(:error)

  ensure
    files.each { |f| f.is_a?(Tempfile) ? f.close! : f.close }
  end
  
  protected
    def update_status(status)
      register_status(:status => status, :output => @output, :length => @length)
    end

end
