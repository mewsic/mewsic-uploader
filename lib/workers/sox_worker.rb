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

    update_status(:idle)
  end

  def run
    files = []
    @tracklist.each do |track|
      debugger
      if SoxEffect.needed?(track)
        tempfile = Tempfile.open('effect')

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

  rescue SoxError
    puts "exception: #{$!}"
    update_status(:error)

  ensure
    files.each { |f| f.respond_to? :close! ? f.close! : f.close }
  end
  
  protected
    def update_status(status)
      register_status(:status => status, :output => @output)
    end

end
