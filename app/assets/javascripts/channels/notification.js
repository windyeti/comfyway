$(document).ready(function() {
  App.cable.subscriptions.create({channel: 'NotificationChannel'}, {
    connected: function() {
      this.perform('follow')
    },
    received: function(data) {
      if(data.state == "start") {
        $('body').prepend(
          "<div class='state_process start'>" +
          "<button type='button' class='close'>&#x2715</button>" +
          "<div class='notification_message'>" + data.message + "</div>"
          + "</div>")
      }
      if(data.state == "finish") {
        $(".state_process.start").remove();
        $('body').prepend(
          "<div class='state_process finish'>" +
          "<button type='button' class='close'>&#x2715</button>" +
          "<div class='notification_message'>" + data.message + "</div>"
          + "</div>")
      }
      $(".state_process .close").on('click', function() {
        $(this).closest('.state_process').remove();
      })
    }
  });
});
