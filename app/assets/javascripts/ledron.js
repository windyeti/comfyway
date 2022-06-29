$(document).ready(function () {
  $(".file_field").on('change',function(_event){
    var $self = $(this);
    console.log($self)
    var filename=$self.val();
    if(filename !== '') {
      $self.parent().find("input[type='submit']").attr('disabled', false);
    } else {
      $self.parent().find("input[type='submit']").attr('disabled', true);
    }
  })
});
