$(document).ready ->
  $(".panel-title .signature").click ->
    $(this).parent().parent().parent().find('.panel-body').toggle()
