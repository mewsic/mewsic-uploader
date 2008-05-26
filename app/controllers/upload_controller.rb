class UploadController < ApplicationController
  def index
    data = params[:Filedata]    
    name = params[:new_name]
    
    @data_file = DataFile.save(data, name, MP3_OUTPUT_DIR)
    
    render :nothing => true
  end
end
