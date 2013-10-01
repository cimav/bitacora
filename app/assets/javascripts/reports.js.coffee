# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on("click", "#reports-nav li", () ->
  url = $(this).data('link')
  $("#reports-nav li").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#reports-main-panel').empty().html(html)
  )
)
