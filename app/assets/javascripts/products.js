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


  $('#deactivatedAll').click(function(event) {
    // event.preventDefault();
    var array = [];
    $('#products_table :checked').each(function() {
      array.push($(this).val());
    });

    $.ajax({
      type: "POST",
      url: '/products/deactivated_selected' + '.json',
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
            $(".product_id_" + this).addClass('deactivated').removeClass('exist_in_insales')
          });
          $('#products_table :checked, #selectAll').each(function() {
            $(this).prop('checked', false);
          });
          var $active_products_count = $("#active_products_count");
          $active_products_count.text(
            $active_products_count.text() - data.ids.length
          );

          var $active_products_span = $active_products_count.closest('span');
          if (+$active_products_count.text() > 40000) {
            $active_products_span.addClass('product_count_over_limit')
          }
          else {
            $active_products_span.removeClass('product_count_over_limit')
          }

          // alert(data.message);
          // location.reload();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    })
  });

  $('#deleteAll').click(function(event) {
    var result = confirm("Вы уверенны?");
    if(!result) return false;
    // event.preventDefault();
    $('#products_table :checked').each(function() {
      var id = $(this).val();
      $.ajax({
        type: "DELETE",
        url: `/products/${id}`,
        // url: $(this).attr('href') + '.json',
        data: {
          id: id
        },
        // beforeSend: function() {
        //   return confirm("Вы уверенны?");
        // },
        success: function(data, textStatus, jqXHR) {
          if (data.status === 'okey') {
            $(data.id).each(function() {
              $(".product_id_" + this).remove();
            });
          }
        },
        error: function(jqXHR, textStatus, errorThrown) {
          console.log(jqXHR);
        }
      })
    });
  });

  $("#active_products_count").on("change", function(){
    var $this = $(this).closest('span');
    if (+$this.text() > 40000) {
      $this.addClass('product_count_over_limit')
    }
    else {
      $this.removeClass('product_count_over_limit')
    }
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
          $('#products_table :checked, #selectAll').each(function() {
            $(this).prop('checked', false);
          });
          var $active_products_count = $("#active_products_count");
          $active_products_count.text(
            +$active_products_count.text() + data.ids.length
          );

          var $active_products_span = $active_products_count.closest('span');
          if (+$active_products_count.text() > 40000) {
            $active_products_span.addClass('product_count_over_limit')
          }
          else {
            $active_products_span.removeClass('product_count_over_limit')
          }
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


