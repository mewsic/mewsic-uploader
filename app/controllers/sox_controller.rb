require 'tracklist'

class SoxController < ApplicationController
  def index
    @worker_key = random_md5

    MiddleMan.new_worker :worker => :sox_worker, :job_key => @worker_key,
                         :data => {
                           :tracks => Tracklist.new(params[:song]),
                           :output => random_output_file
                         }

    MiddleMan.worker(:sox_worker, @worker_key).run

    render_worker_status

  rescue TracklistError
    render :text => $!.to_s, :status => :bad_request
  end
  
  def status(worker = nil)
    @worker_key = params[:worker]

    delete_worker_if_finished :sox_worker, @worker_key
    render_worker_status
  end

  private

    def worker_status
      MiddleMan.worker(:sox_worker, @worker_key).ask_status || Hash.new('')
    end

end
