class AlbumsController < ApplicationController
  
  # Provide a downloadable album that has already been created
  def download
    file_path = "#{ALBUM_CACHE_PATH}#{params[:id]}.zip"
    if File.exists? file_path
      send_file file_path, :type => "audio/mpeg", :disposition => "attachment", :filename => "album.zip", :length => File.size(file_path)
    else
      render :text => "Invalid album request"
    end
  end
  
end
