########################################
# Global constants (app-wide settings) #
########################################

# Path for writing temporary files (such as downloadable tracks)
TMP_PATH = "#{Rails.root}/tmp/"           # Location for writing temporary files
ALBUM_CACHE_SIZE = 500.megabytes      # Maximum size of album zipfile cache

# Path for writing temporary files such as Excel files before exporting
if Rails.env == 'development' || Rails.env == 'test'
  ALBUM_CACHE_PATH = "/htdocs/app_content/phishtracks/album_zip_cache/"
else
  #ALBUM_CACHE_PATH = "???"
end