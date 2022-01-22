$(document).ready(function() {
  App.cable.subscriptions.create({channel: 'NotificationChannel'}, {
    connected: function() {
      this.perform('follow')
    },
    received: function(data) {
      if(data.status == "progress") {
        var $status_process = $(".status_process");
        var padding = 5;
        var $progress_bar = $(".status_process.start."  + data.distributor + "." + data.process + " ." + data.status);
        var new_width = (($status_process.width() + padding*2)/100)*data.percent;
        console.log(new_width);
        $progress_bar.css({"width": new_width + "px"});
        return
      }

      if(data.status == "start") {
        $(".status_process.finish." + data.distributor + "." + data.process).remove();

        $(".form_import #file").val('');
        $(".form_import input[type='submit']").attr('disabled', true);
      }

      if(data.status == "finish") {
        $(".status_process.start." + data.distributor + "." + data.process).remove();
      }

      var $div = $("<div>").addClass("status_process").addClass(data.status).addClass(data.distributor).addClass(data.process);
      $('body').prepend($div.html(
        "<div class='notification_message'>" +
          "<div class='progress'></div>" +
          "<div class='message_process'>" + data.message + "</div>" +
          "<button type='button' class='close'><span class='oi oi-x'></span></button>" +
        "</div>"
      ));

      $(".status_process .close").on('click', function() {
        $(this).closest('.status_process').remove();
      });

      $(".status_process.finish").delay(5000).fadeOut('slow', this.remove)
    }
  });
});
