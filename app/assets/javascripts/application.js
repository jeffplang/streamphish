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
//= require h5bp

// global namespace for stuff
var SP = {};

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

  
  $("#test1").on('click', function(e) {
    $.ajax({
      url: '/shows/1984-12-01/request_download',
      dataType: 'json',
      success: function(data) {
        if (data.status == "Ready") {
          location.href = data.url;
        } else {
          alert(data.status);
          // TODO Bring up a popover with ajax loader and poll every few seconds
          // Close popover once file has started downloading
        }
      }
    });
  });
  
});