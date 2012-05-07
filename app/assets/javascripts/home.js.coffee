# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

current_sample = 0

#------------
# MY REQUESTS
#------------
$('#add-new-button')
  .live('click', () ->
    url = '/service_requests/new'
    $.get(url, {}, (html) ->
      $('#my-requests-area').html(html)
    )
  )

@getServiceRequest = getServiceRequest = (id) ->
  url = '/service_requests/' + id
  $.get(url, {}, (html) ->
    $('#my-requests-area').html(html)
  )

$('#sample-header')
  .live('click', () ->
    $('#sample-list').toggle()
  )

$("#add-new-sample-button")
  .live("click", () ->
    $("#new-sample-dialog").dialog('open')
  )

$("#add-new-sample-link")
  .live("click", () ->
    $("#new-sample-dialog").dialog('open')
  )

@getSample = getSample = (id) ->
    url = '/samples/' + id
    current_sample = id
    $.get(url, {}, (html) ->
      $('#no-samples').remove()
      $('#request-workarea').html(html)
    )

$('.sample-details')
  .live('click', () ->
    getSample($(this).attr('sample_id'))
  )

$('#add-service')
  .live('click', () ->
    $("#add-service-dialog").dialog('open')
  )

$('#add-service-dialog')
  .live("dialogopen", (event, ui) ->
    labServicesLiveSearch()
  )


labServicesLiveSearch = () ->
  $("#laboratory-services-search-box").addClass("loading")
  form = $("#laboratory-services-live-search")
  url = '/laboratory_services/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#laboratory-services-search-box").removeClass("loading")
    $("#laboratory-services-list").html(html)
    $("#laboratory-services-list .lab-service-item:first").click()
  )

$('.lab-service-item')
  .live('click', () ->
    $('.lab-service-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/laboratory_services/' + $(this).attr('laboratory_service_id') + '/for_sample/' + current_sample
    $.get(url, {}, (html) ->
      $('#service-details').html(html)
    )
  )

$('#new-requested-service-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.data('origText', $(this).text())
    $submitButton.text("Agregando...")
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $("#add-service-dialog").dialog('close')
    getSampleRequestedServices(res['sample_id'])
    getRequestedService(res['sample_id'], res['id'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.text($(this).data('origText'))
    $submitButton.attr('disabled', 'disabled').addClass('disabled')
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

@getRequestedService = getRequestedService = (sample_id, id) ->
  url = '/samples/' + sample_id + '/requested_services/' + id
  current_requested_service = id
  $.get(url, {}, (html) ->
    $('.requested_service').removeClass('selected')
    $('#requested_service_' + id).addClass('selected')
    $('#sample-workarea').html(html)
  )

getSampleRequestedServices = (sample_id) ->
  url = '/samples/' + sample_id + '/requested_services_list'
  $.get(url, {}, (html) ->
    $('#sample-services').html(html)
  )

$('.requested_service')
  .live('click', () ->
    getRequestedService(current_sample, $(this).attr('requested_service_id'))
  )

$('#new-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.data('origText', $(this).text())
    $submitButton.text("Creando...")
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $("#new-sample-dialog").dialog('close')
    getSample(res['id'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.text($(this).data('origText'))
    $submitButton.attr('disabled', 'disabled').addClass('disabled')
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#new-request-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.data('origText', $(this).text())
    $submitButton.text("Creando...")
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getServiceRequest(res['id'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.text($(this).data('origText'))
    $submitButton.attr('disabled', 'disabled').addClass('disabled')
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#-----------
# LABORATORY
#-----------
@labReqServicesLiveSearch = labReqServicesLiveSearch = () ->
  $("#lab-req-serv-search-box").addClass("loading")
  form = $("#lab-req-serv-live-search")
  url = '/laboratory/' + form.attr('laboratory_id')  + '/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#lab-req-serv-search-box").removeClass("loading")
    $("#lab-req-serv-list").html(html)
    $("#lab-req-serv-list .lab-req-serv-item:first").click()
  )

$('.lab-req-serv-item')
  .live('click', () ->
    $('.lab-req-serv-item').removeClass('selected')
    $(this).addClass('selected')
    sample_id = $(this).attr('sample_id')
    req_serv_id = $(this).attr('requested_service_id')
    url = '/samples/' + sample_id + '/requested_services/' + req_serv_id
    current_requested_service = req_serv_id
    $.get(url, {}, (html) ->
      $('#lab-req-serv-workarea').html(html)
    )
  )

#-------------
# ACTIVITY LOG
#-------------
getActivityLog = (id) ->
  url = '/activity_log/' + id
  $.get(url, {}, (html) ->
    $('#activity_log').html(html)
  )

$('#new-activity-log-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.data('origText', $(this).text())
    $submitButton.text("Enviando...")
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getActivityLog(res['id'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
    $submitButton = $(this).find('input[type="submit"]')
    $submitButton.text($(this).data('origText'))
    $submitButton.attr('disabled', 'disabled').addClass('disabled')
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )



#-----------
# NAVIGATION
#-----------
$('#nav-home')
  .live('click', () ->
    url = '/home'
    setHash('#!/home', true)
    $('.nav-item').removeClass('selected')
    $('#nav-home').addClass('selected')
  )

$('#nav-my-requests')
  .live('click', () ->
    url = '/my-requests'
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-my-requests').addClass('selected')
  )

$('.nav-lab') 
  .live('click', () ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-laboratory-' + lab_id).addClass('selected')
  )

#-------
# ERRORS
#-------
showFormErrors = (xhr, status, error) ->
  try 
    res = $.parseJSON(xhr.responseText)
  catch err
    res['errors'] = { generic_error: "Error:" + err.description }

  showFlash(res['flash']['error'], 'error')

  for e in res['errors']  
    errorMsg = $('<div>' + res['errors'][e] + '</div>').addClass('error-message')
    $('#field_' + model_name + '_' + e.replace('.', '_')).addClass('with-errors').append(errorMsg)
  

showFlash = (msg, type) ->
  $("#flash-notice").removeClass('success').removeClass('notice').removeClass('info')
  $("#flash-notice").addClass(type).html(msg)
  $("#flash-notice").slideDown()
  $("#flash-notice").delay(1500).slideUp() if (type != 'error') 




#--------------
# LOCATION HASH
#-------------- 
setHash = (h, get_url) ->
  hash = h
  window.location.hash = hash
  checkHash() if get_url

checkHash = () ->
  if window.location.hash != hash
    hash = window.location.hash
    if (hash.slice(0, 2) == '#!' && hash.length > 3) 
      url = hash.slice(2 - hash.length) + '?__from__=url'
      $.get(url, {}, (html) ->
        $('#workarea').html(html)
      )
