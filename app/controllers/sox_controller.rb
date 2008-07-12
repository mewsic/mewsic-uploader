require 'tracklist'

class SoxController < ApplicationController
  def index
    @worker_key = random_md5

    MiddleMan.ask_work :worker => :sox_worker, :worker_method => :run,
                       :data => {
                          :key => @worker_key,
                          :tracks => Tracklist.new(params[:song]),
                          :output => random_output_file
                       }

    render_worker_status

  rescue TracklistError
    render :text => $!.to_s, :status => :bad_request
  end
  
  def status(worker = nil)
    @worker_key = params[:worker]
    render_worker_status
  end

  private
    def worker_status
      MiddleMan.worker(:sox_worker).ask_status[@worker_key] || Hash.new('')
    end

end
