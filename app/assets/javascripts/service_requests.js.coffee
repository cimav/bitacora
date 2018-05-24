# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).on('click', '.sample-header .identification', () ->
  sample_id = $(this).data('sample-id')
  $("#sample-item-#{sample_id}").toggleClass('opened')
)

$(document).on('click', '#load-more-sr-a', () ->
  q = $(this).data('q')
  o = $(this).data('o')
  url = '/service_requests/live_search?q=' + q + '&o=' + o
  $.get(url, {}, (html) ->
    $('#div_load-more-sr-' + o).empty().html(html)
  )
)


$(document).on('click', '.edit-sample-btn', () ->
  sample_id = $(this).data('sample-id')
  url = '/samples/edit_dialog/' + sample_id
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#edit-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getServiceRequest(res['service_request_id'])
  )
$(document).on('ajax:error', '#edit-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


$(document).on('click', '.sample-ids .list-header', () ->
  sample_id = $(this).data('sample-id')
  $("#sample-ids-#{sample_id}").toggleClass('opened')
)

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
  $(this).prop('disabled', true)
  url = '/service_requests/' + id + '/send_quote';
  $.post(url, { suggested_price: $('#suggested_price').val(), estimated_time: $('#estimated_time').val() }, (html) ->
    getServiceRequest(id)

    $('#folder-work-panel').empty().html(html)
  )
)


$(document).on('click', '#send-report-button', () ->
  id = $(this).data('id')
  $(this).prop('disabled', true)
  url = '/service_requests/' + id + '/view_report';
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('click', '#send-report-to-vinculacion', () ->
  id = $(this).data('id')
  $(this).prop('disabled', true)
  form = $('#send-report-form')
  formData = form.serialize()
  url = '/service_requests/' + id + '/send_report';
  $.post(url, formData, (html) ->
    getServiceRequestActions(id)
    $('#folder-work-panel').empty().html(html)
  )
  false
)


$(document).on('click', '#send-report-tipo-2-button', () ->
  id = $(this).data('id')
  $(this).prop('disabled', true)
  url = '/service_requests/' + id + '/view_report_tipo_2';
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('click', '#send-report-tipo-2-to-vinculacion', () ->
  id = $(this).data('id')
  $(this).prop('disabled', true)
  form = $('#send-report-form')
  formData = form.serialize()
  url = '/service_requests/' + id + '/send_report_tipo_2';
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
  $(this).prop('disabled', true)
  id = $(this).data('id')
  url = '/service_requests/' + id + '/add_collaborator';
  $('#collaborators').hide();
  collab_id = $('#collaborator_id').val();
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



# PROYECTOS VINCULACION

$(document).on('click', '#send-project-quote-button', () ->
  id = $(this).data('id')
  $(this).prop('disabled', true)
  url = '/service_requests/' + id + '/send_request_department_auth';

  $.post(url, {}, (html) ->
    url = '/#!/service_requests/' + id 
    window.location = url
  )
  false
)