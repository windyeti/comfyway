$(document).ready(function(e) {
  var $container_table = $('#container_for_table_with_data');

  var header_height = $('.header').height();
  var filter_height = $('#filter_menu').height();
  var pagination_height = $('.digg_pagination').height();

  $container_table.height($(window).height() - header_height - filter_height - pagination_height - 60);

  $(window).resize(function() {
    var header_height = $('.header').height();
    var filter_height = $('#filter_menu').height();
    var pagination_height = $('.digg_pagination').height();

    $container_table.height($(window).height() - header_height - filter_height - pagination_height - 60);
  })
});


