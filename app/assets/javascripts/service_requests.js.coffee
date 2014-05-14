# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on('change', '#service_request_request_type_id', () ->
  $('#cg_ServiceRequest_link').hide();
  $('#cg_ServiceRequest_description').hide();
  $('#cg_ServiceRequest_supervisor').hide();
  $('#cg_ServiceRequest_submit').hide();
  url = "/service_requests/form/#{$(this).val()}"
  $.get(url, {}, (html) ->
    $('#extra-form').empty().html(html)
  )
)

$(document).on('click', '#send-quote-button', () ->
  id = $(this).data('id')
  url = '/service_requests/' + id + '/quotation';
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('click', '#send-quote-to-vinculacion', () ->
  id = $(this).data('id')
  url = '/service_requests/' + id + '/send_quote';
  $.post(url, {}, (html) ->
    getServiceRequestActions(id)
    $('#folder-work-panel').empty().html(html)
  )
)
