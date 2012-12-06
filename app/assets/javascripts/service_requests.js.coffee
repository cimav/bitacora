# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('#service_request_request_type_id')
  .live('change', () ->
    url = "/service_requests/form/#{$(this).val()}"
    $.get(url, {}, (html) ->
      $('#extra-form').empty().html(html)
    )
  )
