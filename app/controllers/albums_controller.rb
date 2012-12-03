class AlbumsController < ApplicationController
  
  # Provide a downloadable album that has already been created
  def download
    album = Album.find_by_md5(params[:id])
    # raise album.inspect
    if album and album.completed_at and File.exists? album.zip_file.path
      send_file album.zip_file.path, :type => album.zip_file.content_type, :disposition => "attachment", :filename => "Phish - #{album.name}", :length => album.zip_file.size
    else
      render :text => "Invalid album request"
    end
  end
  
end
