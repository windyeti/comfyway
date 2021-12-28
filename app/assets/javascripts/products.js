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

$(document).ready(function() {
  $('#selectAll').click(function() {
    if (this.checked) {
      $(':checkbox').each(function() {
        this.checked = true;
        console.log('CCCCC')
      });
    } else {
      $(':checkbox').each(function() {
        this.checked = false;
      });
    }
  });


  $('#deleteAll').click(function(event) {
    // event.preventDefault();
    var array = [];
    $('#products_table :checked').each(function() {
      array.push($(this).val());
    });

    $.ajax({
      type: "POST",
      url: '/products/delete_selected' + '.json',
      // url: $(this).attr('href') + '.json',
      data: {
        ids: array
      },
      beforeSend: function() {
        return confirm("Вы уверенны?");
      },
      success: function(data, textStatus, jqXHR) {
        if (data.status === 'okey') {
          $(data.ids).each(function() {
            $(".product_id_" + this).addClass('deactivated')
          });
          $('#products_table :checked').each(function() {
            $(this).prop('checked', false);
          });
          // alert(data.message);
          // location.reload();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    })
  });

  $('#showAll').click(function(event) {
    // event.preventDefault();
    var array = [];
    $('#products_table :checked').each(function() {
      array.push($(this).val());
    });

    $.ajax({
      type: "POST",
      url: '/products/show_selected' + '.json',
      // url: $(this).attr('href') + '.json',
      data: {
        ids: array
      },
      success: function(data, textStatus, jqXHR) {
        if (data.status === 'okey') {
          $(data.ids).each(function() {
            $(".product_id_" + this).removeClass('deactivated')
          });
          $('#products_table :checked').each(function() {
            $(this).prop('checked', false);
          });
          // alert(data.message);
          // location.reload();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    })
  });
});


