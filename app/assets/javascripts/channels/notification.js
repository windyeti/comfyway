$(document).ready(function() {
  App.cable.subscriptions.create({channel: 'NotificationChannel'}, {
    connected: function() {
      this.perform('follow')
    },
    received: function(data) {
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
        "<button type='button' class='close'>&#x2715</button>" +
        "<div class='notification_message'>" + data.message + "</div>"
      ));

      $(".status_process .close").on('click', function() {
        $(this).closest('.status_process').remove();
      });

      $(".status_process.finish").delay(5000).hide(0)
    }
  });
});
