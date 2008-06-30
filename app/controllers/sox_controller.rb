require 'tracklist'

class SoxController < ApplicationController
  def index
    if request.get?
      render and return
    end

    @worker_key = random_md5

    tracklist = Tracklist.new(params[:song])
    output = random_output_file

    MiddleMan.new_worker :worker => :sox_worker, :job_key => @worker_key,
                         :data => {:tracks => tracklist, :output => output}

    MiddleMan.worker(:sox_worker, @worker_key).run

    render_worker_status

  rescue TracklistError
    render :text => $!.to_s, :status => :bad_request
  end
  
  def status(worker = nil)
    @worker_key = params[:worker]

    if [:finished, :error].include? worker_status[:status]
      MiddleMan.delete_worker(:worker => :sox_worker, :job_key => @worker_key)
    end 

    render_worker_status
  end

  private

    def worker_status
      MiddleMan.worker(:sox_worker, @worker_key).ask_status || Hash.new('')
    end

end
