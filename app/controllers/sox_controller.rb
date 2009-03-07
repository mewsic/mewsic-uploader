require 'tracklist'

class SoxController < ApplicationController
  def index
    @worker_key = random_md5

    MiddleMan.worker(:sox_worker).async_run(
      :arg => {
        :key => @worker_key,
        :tracks => Tracklist.new(params[:tracks]),
        :output => random_output_file,
        :song_id => params[:song_id],
        :user_id => params[:id]
      })

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
      MiddleMan.worker(:sox_worker).ask_result(@worker_key) || Hash.new('')
    end

end
