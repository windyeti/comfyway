$(document).ready(function () {
  $("#file").on('change',function(_event){
    var filename=$(this).val();
    if(filename!=='') {
      $("form.form_import input[type='submit']").attr('disabled', false);
    } else {
      $("form.form_import input[type='submit']").attr('disabled', true);
    }
  })
});
