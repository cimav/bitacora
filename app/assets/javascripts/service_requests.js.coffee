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


$(document).on('click', '#send-report-button', () ->
  id = $(this).data('id')
  url = '/service_requests/' + id + '/view_report';
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('click', '#send-report-to-vinculacion', () ->
  id = $(this).data('id')
  form = $('#send-report-form')
  formData = form.serialize()
  url = '/service_requests/' + id + '/send_report';
  $.post(url, formData, (html) ->
    getServiceRequestActions(id)
    $('#folder-work-panel').empty().html(html)
  )
  false
)


$(document).on('click', '#add-collaborator-button', () ->
  id = $(this).data('id')
  url = '/service_requests/' + id + '/add_collaborator_dialog';
  $('#add-collaborator-button').hide();
  $.get(url, {}, (html) ->
    $('#collaborator-panel').empty().html(html)
  )
)

$(document).on('click', '#add-collaborator-save', () ->
  id = $(this).data('id')
  url = '/service_requests/' + id + '/add_collaborator';
  $('#collaborators').hide();
  collab_id = $('#collaborator_id').select2('data').id;
  $.post(url, {'collaborator_id': collab_id}, (html) ->
    $('#collaborator-panel').empty().html(html)
    url = '/service_requests/' + id + '/get_collaborators';
    $('#collaborators').show();
    $.get(url, {}, (html) ->
      $('#collaborators').empty().html(html)
    )
  )
)

$(document).on('ajax:beforeSend', '.collaborator-item .close', (evt, xhr, settings) ->
    $(".equipment-row").removeClass('error')
  )
$(document).on('ajax:success', '.collaborator-item .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    collab_id = res['id']
    showFlash(res['flash']['notice'], 'success')
    $("#collaborator-item#{collab_id}").remove()
    reloadEquipmentTable()
  )

$(document).on('ajax:error', '.collaborator-item .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'error')
  )