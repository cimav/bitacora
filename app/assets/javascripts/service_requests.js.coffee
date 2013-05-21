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

newClientDialog = () ->
  $("#new-client-dialog").remove()
  $('body').append('<div id="new-client-dialog"></div>')
  url = '/clients/new_dialog/'
  $.get(url, {}, (html) ->
    $('#new-client-dialog').empty().html(html)
    $('#add-new-client-modal').modal({ keyboard:true, backdrop:true, show: true });
  )

$(document).on('click', '#add-new-client', () ->
    newClientDialog()
  )

$(document).on('ajax:beforeSend', '#new-client-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )

$(document).on('ajax:success', '#new-client-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    selectClient(res['id'], res['name'])
    $('#add-new-client-modal').modal('hide').remove()
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#new-client-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

selectClient = (id, name) ->
  $('#select-client-typeahead').val(name)
  $.get('/clients/info', { query: name }, (data) ->
    $('#client-info').html(data)
    $('#cg_ExternalRequest_client_typeahead').hide()
  )

newClientContactDialog = () ->
  $("#new-client-contact-dialog").remove()
  $('body').append('<div id="new-client-contact-dialog"></div>')
  url = '/client_contacts/new_dialog/' + $('#service_request_external_request_attributes_0_client_id').val()
  $.get(url, {}, (html) ->
    $('#new-client-contact-dialog').empty().html(html)
    $('#add-new-client-contact-modal').modal({ keyboard:true, backdrop:true, show: true });
  )

$(document).on('click', '#add-new-client-contact', () ->
    newClientContactDialog()
  )
  
$(document).on('ajax:beforeSend', '#new-client-contact-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )

$(document).on('ajax:success', '#new-client-contact-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    selectClientContact(res['client_id'], res['id'])
    $('#add-new-client-contact-modal').modal('hide').remove()
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#new-client-contact-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

selectClientContact = (client_id, id) ->
  $.get('/client_contacts/combo/' + client_id, {}, (data) ->
    $('#cg_Client_Contact .controls').html(data)
    $('#service_request_external_request_attributes_0_client_contact_id').val(id)
  )
