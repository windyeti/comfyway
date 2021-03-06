// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery3
//= require activestorage
//= require popper
//= require bootstrap

//= require jquery_ujs
//= require best_in_place
//= require jquery-ui
//= require best_in_place.jquery-ui

//= require_self
//= require_tree .

$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();
});

$(document).ready(function () {
  $("#file").on('change',function(_event){
    var filename=$(this).val();
    if(filename!=='') {
      $("form.form_import input[type='submit']").attr('disabled', false);
    }
  })
});
