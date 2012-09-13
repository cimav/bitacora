# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

current_sample = 0
current_request = 0
current_requested_service = 0

#--------
# HELPERS
#--------
$('html').click( (e) ->
  if e.target.id != 'search-results'
    $('#search-input').val('')
    $('#search-results').hide()
)


@calcFrameHeight = calcFrameHeight = (id) ->
  iframe = document.getElementById(id)
  try

    if iframe.contentDocument
      innerDoc = iframe.contentDocument
    else
      innerDoc = iframe.contentWindow.document

    if innerDoc.body.offsetHeight
      iframe.height = innerDoc.body.offsetHeight + 400
    else 
      if iframe.Document && iframe.Document.body.scrollHeight
        iframe.height = iframe.Document.body.scrollHeight + 400

  catch err
    alert(err.message)

#------------
# MY REQUESTS
#------------
my_request_search_results = false

requestsLiveSearch = () -> 
  #return false if $("#search-box").val().length < 3
  form = $('#live-search')
  url = '/service_requests/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $('#search-results').empty().html(html)
    $('#search-results').show()
  )

$('#search-box')
  .live('keyup', () ->
    requestsLiveSearch() 
  )
  .live('click', () ->
    requestsLiveSearch() 
  )

$('.service-request-item')
  .live('click', () ->
    $('#search-results').hide()
    getServiceRequest($(this).attr('service_request_id'))
  )


$('#add-new-button')
  .live('click', () ->
    url = '/service_requests/new'
    $.get(url, {}, (html) ->
      $('#my-requests-area').empty().html(html)
    )
  )

@getServiceRequest = getServiceRequest = (id) ->
  url = '/service_requests/' + id
  $.get(url, {}, (html) ->
    current_request = id
    $('#my-requests-area').empty().html(html)
  )

$('#sample-header')
  .live('click', () ->
    $('#sample-list').toggle()
  )

$('#select-sample-sample-button')
  .live('click', () ->
    $('#sample-list').toggle()
  )

$('#activity-tab-link') 
  .live('click', () ->
    $('#requested-service-tabs ul li').removeClass('selected')
    $(this).closest('li').addClass("selected"); 
    $('.tab-content').hide()
    $('#activity-tab').show()
  )

$('#files-tab-link') 
  .live('click', () ->
    $('#requested-service-tabs ul li').removeClass('selected')
    $(this).closest('li').addClass("selected"); 
    $('.tab-content').hide()
    $('#files-tab').show()
    calcFrameHeight('files_iframe')
  )


newSampleDialog = () ->
   $("#new-sample-dialog").remove()
   $('#container').append('<div title="Agregar Muestra" id="new-sample-dialog"></div>')
   $("#new-sample-dialog").dialog({ autoOpen: true, width: 350, height: 430, modal:true })

$("#add-new-sample-button")
  .live("click", () ->
    newSampleDialog()
  )

$("#add-new-sample-link")
  .live("click", () ->
    newSampleDialog()
  )

$( "#new-sample-dialog" )
  .live("dialogopen", (event, ui) ->
    url = '/samples/new_dialog/' + current_request
    $.get(url, {}, (html) ->
      $('#new-sample-dialog').empty().html(html)
    )
  )

@getSample = getSample = (id) ->
    url = '/samples/' + id
    current_sample = id
    $.get(url, {}, (html) ->
      $('#no-samples').remove()
      $('#request-workarea').empty().html(html)
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

$('#service_type')
  .live('change', () ->
    labServicesLiveSearch()
  )

$('#laboratory')
  .live('change', () ->
    labServicesLiveSearch()
  )

$('#laboratory-services-search-box')
  .live('keyup', () ->
    labServicesLiveSearch()
  )


labServicesLiveSearch = () ->
  $("#laboratory-services-search-box").addClass("loading")
  form = $("#laboratory-services-live-search")
  url = '/laboratory_services/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#laboratory-services-search-box").removeClass("loading")
    $("#laboratory-services-list").empty().html(html)
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
    $('#requested-service-workarea').empty().html(html)
  )

getSampleRequestedServices = (sample_id) ->
  url = '/samples/' + sample_id + '/requested_services_list'
  $.get(url, {}, (html) ->
    $('#sample-services').empty().html(html)
  )

$('.requested_service')
  .live('click', () ->
    getRequestedService($(this).attr('sample_id'), $(this).attr('requested_service_id'))
  )

$('#new-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $("#new-sample-dialog").dialog('close').dialog('destroy').remove()
    getSample(res['id'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#new-request-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
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
    $("#lab-req-serv-list").empty().html(html)
    $("#lab-req-serv-list .lab-req-serv-item:first").click()
  )

$('#lrs_status')
  .live('change', () ->
    labReqServicesLiveSearch()
  )

$('#lrs_requestor')
  .live('change', () ->
    labReqServicesLiveSearch()
  )

$('#lrs_assigned_to')
  .live('change', () ->
    labReqServicesLiveSearch()
  )

$('#req-serv-search-box')
  .live('keyup', () ->
    labReqServicesLiveSearch()
  )

#-------------
# ACTIVITY LOG
#-------------
getActivityLog = (id) ->
  url = '/activity_log/' + id
  $.get(url, {}, (html) ->
    $('#activity_log').empty().html(html)
  )

$('#new-activity-log-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
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
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#--------
# ACTIONS
#--------
$('#requested-service-status')
  .live('click', () ->
    $('#action-list').toggle()
  )

# Change color
changeSampleTagColor = (rs, new_status) ->
  $("#requested_service_" + rs + " .sample-tag .rs-consecutive").removeClass("status_-1").removeClass("status_1").removeClass("status_2").removeClass("status_3").removeClass("status_4").removeClass("status_5").removeClass("status_6").removeClass("status_99")
  $("#requested_service_" + rs + " .sample-tag .rs-quantity").removeClass("status_-1").removeClass("status_1").removeClass("status_2").removeClass("status_3").removeClass("status_4").removeClass("status_5").removeClass("status_6").removeClass("status_99")
  $("#requested_service_" + rs + " .sample-tag .rs-consecutive").addClass("status_" + new_status)
  $("#requested_service_" + rs + " .sample-tag .rs-quantity").addClass("status_" + new_status)

# INITIAL
$('#change_status_initial') 
  .live('click', () ->
    $("#initial-sample-dialog").remove()
    $('#container').append('<div title="Agregar Muestra" id="initial-sample-dialog"></div>')
    $("#initial-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/initial_dialog'
    $.get(url, {}, (html) ->
      $('#initial-sample-dialog').empty().html(html)
    )
  )

$('#initial-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#initial-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 1)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# RECEIVED
$('#change_status_received') 
  .live('click', () ->
    $("#receive-sample-dialog").remove()
    $('#container').append('<div title="Recibir Muestra" id="receive-sample-dialog"></div>')
    $("#receive-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/receive_dialog'
    $.get(url, {}, (html) ->
      $('#receive-sample-dialog').empty().html(html)
    )
  )

$('#receive-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#receive-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 2)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# ASSIGN
$('#change_status_assigned')
  .live('click', () ->
    $("#assign-sample-dialog").remove()
    $('#container').append('<div title="Asignar Servicio" id="assign-sample-dialog"></div>')
    $("#assign-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/assign_dialog'
    $.get(url, {}, (html) ->
      $('#assign-sample-dialog').empty().html(html)
    )
  )

$('#assign-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#assign-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 3)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# SUSPEND
$('#change_status_suspended')
  .live('click', () ->
    $("#suspend-sample-dialog").remove()
    $('#container').append('<div title="Suspender Servicio" id="suspend-sample-dialog"></div>')
    $("#suspend-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/suspend_dialog'
    $.get(url, {}, (html) ->
      $('#suspend-sample-dialog').empty().html(html)
    )
  )

$('#suspend-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#suspend-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 4)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# REINIT
$('#change_status_reinit')
  .live('click', () ->
    $("#reinit-sample-dialog").remove()
    $('#container').append('<div title="Reiniciar Servicio" id="reinit-sample-dialog"></div>')
    $("#reinit-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/reinit_dialog'
    $.get(url, {}, (html) ->
      $('#reinit-sample-dialog').empty().html(html)
    )
  )

$('#reinit-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#reinit-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 5)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# START
$('#change_status_in_progress')
  .live('click', () ->
    $("#start-sample-dialog").remove()
    $('#container').append('<div title="Iniciar Servicio" id="start-sample-dialog"></div>')
    $("#start-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/start_dialog'
    $.get(url, {}, (html) ->
      $('#start-sample-dialog').empty().html(html)
    )
  )

$('#start-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#start-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 6)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# FINISH
$('#change_status_finished')
  .live('click', () ->
    $("#finish-sample-dialog").remove()
    $('#container').append('<div title="Finalizar Servicio" id="finish-sample-dialog"></div>')
    $("#finish-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/finish_dialog'
    $.get(url, {}, (html) ->
      $('#finish-sample-dialog').empty().html(html)
    )
  )

$('#finish-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#finish-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], 99)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# CANCEL
$('#change_status_canceled')
  .live('click', () ->
    $("#cancel-sample-dialog").remove()
    $('#container').append('<div title="Cancelar Servicio" id="cancel-sample-dialog"></div>')
    $("#cancel-sample-dialog").dialog({ autoOpen: true, width: 340, height: 400, modal:true })
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/cancel_dialog'
    $.get(url, {}, (html) ->
      $('#cancel-sample-dialog').empty().html(html)
    )
  )

$('#cancel-sample-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    $("#cancel-sample-dialog").dialog('close').dialog('destroy').remove()
    changeSampleTagColor(res['id'], -1)
  )
  .live('ajax:complete', (evt, xhr, status) ->
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
  $("#flash-notice").addClass(type).empty().html(msg)
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
        $('#workarea').empty().html(html)
      )
