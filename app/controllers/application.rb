# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  def input_file(name)
    File.join(FLV_INPUT_DIR, name)
  end

  def output_file(name)
    File.join(MP3_OUTPUT_DIR, name)
  end

  def random_output_file(ext = 'mp3')
    loop do
      path = File.join(MP3_OUTPUT_DIR, random_md5 << '.' << ext)
      return path unless File.exists? path
    end
  end

  def random_md5
    MD5.md5(rand.to_s).to_s
  end

  def render_worker_status
    respond_to do |format|
      format.xml { render :partial => 'shared/worker', :object => worker_status }
    end
  end
end
