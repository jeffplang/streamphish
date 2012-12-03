// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require h5bp

// global namespace for stuff
var SP = {};

request_album = function(request_url, first_call) {
  $.ajax({
    url: request_url,
    dataType: 'json',
    success: function(data) {
      if (data.status == "Ready") {
        $("#download_modal").modal('hide');
        location.href = data.url;
      } else {
        if (first_call) $("#download_modal").modal('show');
        request_album_timeout = setTimeout(function(){ request_album(request_url, false) }, 3000);
      }
    }
  });
}

$(function() {
  $('.epd').on('click', function(e){
    e.preventDefault();
  });
  
  $('li').on('mouseover', function(e) {
    $(this).children('.downloadButton').show();
  });
  $('.songs li').on('mouseout', function(e) {
    $(this).children('.downloadButton').hide()
  });

  $(".download-album").on('click', function(e) {
    e.preventDefault();
    request_album($(this).data('request-url'), true);
  });
  
});