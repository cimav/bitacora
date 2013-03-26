# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

current_sample = 0
current_request = 0
current_requested_service = 0
hash = false

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

@foldersLiveSearch = foldersLiveSearch = () -> 
  #return false if $("#search-box").val().length < 3
  form = $('#folder-live-search')
  url = '/service_requests/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $('#folder-panel .items-placeholder').empty().html(html)
    $("#folder-panel .items-placeholder .items .service-request-item:first").click();
  )

$('#search-box')
  .live('keyup', () ->
    foldersLiveSearch() 
  )
  .live('click', () ->
    foldersLiveSearch() 
  )

$('.service-request-item')
  .live('click', () ->
    $('.service-request-item').removeClass('selected')
    $(this).addClass('selected')
    getServiceRequest($(this).attr('service_request_id'))
  )


$('#add-new-folder-button')
  .live('click', () ->
    url = '/service_requests/new'
    $.get(url, {}, (html) ->
      $('#folder-main-panel').empty().html(html)
    )
  )

@getServiceRequest = getServiceRequest = (id) ->
  url = '/service_requests/' + id
  $.get(url, {}, (html) ->
    current_request = id
    $('#folder-main-panel').empty().html(html)
  )

$('#select-sample-sample-button')
  .live('click', () ->
    $('#sample-list').toggle()
  )

newSampleDialog = () ->
  $("#new-sample-dialog").remove()
  $('body').append('<div id="new-sample-dialog"></div>')
  url = '/samples/new_dialog/' + current_request
  $.get(url, {}, (html) ->
    $('#new-sample-dialog').empty().html(html)
    $('#add-new-sample-modal').modal({ keyboard:true, backdrop:true, show: true });
  )

$("#add-new-sample-button")
  .live("click", () ->
    newSampleDialog()
  )

$("#open-new-sample-modal-link")
  .live("click", () ->
    newSampleDialog()
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

addServiceDialog = () ->
  $("#add-service-dialog").remove()
  $('body').append('<div id="add-service-dialog"></div>')
  url = '/laboratory_services/add_service_dialog/'
  $.get(url, {}, (html) ->
    $('#add-service-dialog').empty().html(html)
    $('#add-service-modal').modal({ keyboard:true, backdrop:true, show: true })
    labServicesLiveSearch()
  )

$('#open-add-service-modal')
  .live('click', () ->
    addServiceDialog()
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

$('#add-service-modal-submit')
  .live('click', () ->
    $('#new-requested-service-form').submit();
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
    $('#add-service-modal').modal('hide').remove()
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
    $('#add-new-sample-modal').modal('hide').remove()
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
    $('#search-filter').val('*')
    $('#search-box').val(res['id'])
    foldersLiveSearch()
    #getServiceRequest(res['id'])
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
    $("#lab-req-serv-panel .items-placeholder").empty().html(html)
    $("#lab-req-serv-panel .items-placeholder .lab-req-serv-item:first").click()
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
  $("#requested_service_" + rs + " .service-bullet").removeClass("status_-1").removeClass("status_1").removeClass("status_2").removeClass("status_3").removeClass("status_4").removeClass("status_5").removeClass("status_6").removeClass("status_99")
  $("#requested_service_" + rs + " .service-bullet").addClass("status_" + new_status)

# INITIAL
$('#change_status_initial')
  .live('click', () ->
    $("#initial-dialog").remove()
    $('body').append('<div id="initial-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/initial_dialog'
    $.get(url, {}, (html) ->
      $('#initial-dialog').empty().html(html)
      $('#initial-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#initial-modal').modal('hide').remove()
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
    $("#receive-dialog").remove()
    $('body').append('<div id="receive-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/receive_dialog'
    $.get(url, {}, (html) ->
      $('#receive-dialog').empty().html(html)
      $('#receive-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#receive-modal').modal('hide').remove()
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
    $("#assign-dialog").remove()
    $('body').append('<div id="assign-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/assign_dialog'
    $.get(url, {}, (html) ->
      $('#assign-dialog').empty().html(html)
      $('#assign-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#assign-modal').modal('hide').remove()
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
    $("#suspend-dialog").remove()
    $('body').append('<div id="suspend-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/suspend_dialog'
    $.get(url, {}, (html) ->
      $('#suspend-dialog').empty().html(html)
      $('#suspend-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#suspend-modal').modal('hide').remove()
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
    $("#reinit-dialog").remove()
    $('body').append('<div id="reinit-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/reinit_dialog'
    $.get(url, {}, (html) ->
      $('#reinit-dialog').empty().html(html)
      $('#reinit-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#reinit-modal').modal('hide').remove()
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
    $("#start-dialog").remove()
    $('body').append('<div id="start-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/start_dialog'
    $.get(url, {}, (html) ->
      $('#start-dialog').empty().html(html)
      $('#start-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#start-modal').modal('hide').remove()
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
    $("#finish-dialog").remove()
    $('body').append('<div id="finish-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/finish_dialog'
    $.get(url, {}, (html) ->
      $('#finish-dialog').empty().html(html)
      $('#finish-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#finish-modal').modal('hide').remove()
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
    $("#cancel-dialog").remove()
    $('body').append('<div id="cancel-dialog"></div>')
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/cancel_dialog'
    $.get(url, {}, (html) ->
      $('#cancel-dialog').empty().html(html)
      $('#cancel-modal').modal({ keyboard:true, backdrop:true, show: true });
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
    $('#cancel-modal').modal('hide').remove()
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

#----------
# LAB ADMIN
#----------

$('.admin-lab')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin'
    setHash('#!' + url, false)
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    alert('Error')
  )

$('#edit-laboratory-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $("#nav-title-#{res['id']}").html(res['name'])
    $("#laboratory-bar h2").html(res['name'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#-------------------
# LAB ADMIN SERVICES
#-------------------
$('.admin-services')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin_services'
    setHash('#!' + url, false)
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    alert('Error')
  )

$('#admin_lab_service_type')
  .live('change', () ->
    adminLabServicesLiveSearch()
  )

$('#admin-lab-services-search-box')
  .live('keyup', () ->
    adminLabServicesLiveSearch()
  )


@adminLabServicesLiveSearch = adminLabServicesLiveSearch = () ->
  $("#admin-lab-services-search-box").addClass("loading")
  form = $("#admin-lab-services-live-search")
  lab_id = form.attr('lab_id')
  url = "/laboratory/#{lab_id}/admin_lab_services_live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#admin-lab-services-search-box").removeClass("loading")
    $("#admin-lab-services-list").empty().html(html)
    $("#admin-lab-services-list .admin-lab-service-item:first").click()
  )

$('.admin-lab-service-item')
  .live('click', () ->
    $('.admin-lab-service-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/laboratory_services/' + $(this).attr('laboratory_service_id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-service-details').html(html)
    )
    url = '/laboratory_services/' + $(this).attr('laboratory_service_id') + '/edit_cost'
    $.get(url, {}, (html) ->
      $('#admin-service-costs').html(html)
    )
  )

$('#edit-laboratory-service-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#add-new-service-button')
  .live('click', () ->
    url = '/laboratory/' + $(this).attr('lab_id') + '/new_service'
    $.get(url, {}, (html) ->
      $('#admin-service-details').empty().html(html)
    )
  )

$('#new-laboratory-service-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-services-search-box').val(res['name'])
    adminLabServicesLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#
# Technicians template
#
$('#add-technician-template')
  .live('click', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_technician'
    $.post(url, 
           { user_id: $('#new_tech_user_id').val(), participation: $('#new_tech_participation').val(), hours: $('#new_tech_hours').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTableTemplate()
     )
   )

updateGrandTotalTemplate = (laboratory_service) ->
  url = '/laboratory_services/' + laboratory_service + '/grand_total'
  $.get(url, {}, (html) ->
    $('#grand_total').empty().html(html)
  )

reloadTechniciansTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/technicians_table'
  $.get(url, {}, (html) ->
    $('#technicians-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$('#technicians-template .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".technician-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#technician_row_#{tech_id}").remove()
    reloadTechniciansTableTemplate()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )

$('.tech_participation_template')
  .live('change', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/update_participation'
    $.post(url, 
           { tech_id: $(this).attr('data-id'), participation: $(this).val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTableTemplate()
     )
  )


$('.tech_hours_template')
  .live('change', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/update_hours'
    $.post(url, 
           { tech_id: $(this).attr('data-id'), hours: $(this).val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTableTemplate()
     )
  )

#
# Equipment template
#
$('#add-equipment-template')
  .live('click', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_equipment'
    $.post(url, 
           { eq_id: $('#new_eq_id').val(), hours: $('#new_eq_hours').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadEquipmentTableTemplate()
     )
   )

reloadEquipmentTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/equipment_table'
  $.get(url, {}, (html) ->
    $('#equipment-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$('#equipment-template .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".equipment-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    eq_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#equipment#{eq_id}").remove()
    reloadEquipmentTableTemplate()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.eq_hours_template')
  .live('change', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/update_eq_hours'
    $.post(url, 
          { eq_id: $(this).attr('data-id'), hours: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadEquipmentTableTemplate()
    )
  )

#
# Materials Template
#
$('#add-material-template')
  .live('click', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_material'
    $.post(url, 
           { mat_id: $('#new_mat_id').val(), quantity: $('#new_mat_qty').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadMaterialTableTemplate()
     )
   )

reloadMaterialTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/materials_table'
  $.get(url, {}, (html) ->
    $('#materials-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$('#materials-template .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".material-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    mat_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#material#{mat_id}").remove()
    reloadMaterialTableTemplate()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.mat_qty_template')
  .live('change', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/update_mat_qty'
    $.post(url, 
          { mat_id: $(this).attr('data-id'), quantity: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadMaterialTableTemplate()
    )
  )

#
# Others template
#
$('#add-other-template')
  .live('click', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_other'
    $.post(url, 
           { other_type_id: $('#new_other_type').val(), concept: $('#new_other_concept').val(), price: $('#new_other_price').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadOthersTableTemplate()
     )
   )

reloadOthersTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/others_table'
  $.get(url, {}, (html) ->
    $('#others-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$('#others-template .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".other-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    other_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#others#{other_id}").remove()
    reloadOthersTableTemplate()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.other_price_template')
  .live('change', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/update_other_price'
    $.post(url, 
          { other_id: $(this).attr('data-id'), price: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadOthersTableTemplate()
    )
  )








#-------
# COSTS
#-------

updateGrandTotal = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/grand_total'
  $.get(url, {}, (html) ->
    $('#grand_total').empty().html(html)
  )

#
# Technicians
#

$('#add-technician')
  .live('click', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_technician'
    $.post(url, 
           { user_id: $('#new_tech_user_id').val(), participation: $('#new_tech_participation').val(), hours: $('#new_tech_hours').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTable()
     )
   )

reloadTechniciansTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/technicians_table'
  $.get(url, {}, (html) ->
    $('#technicians').empty().html(html)
    updateGrandTotal()
  )


$('#technicians .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".technician-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#technician_row_#{tech_id}").remove()
    reloadTechniciansTable()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )

$('.tech_participation')
  .live('change', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_participation'
    $.post(url, 
           { tech_id: $(this).attr('data-id'), participation: $(this).val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTable()
     )
  )


$('.tech_hours')
  .live('change', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_hours'
    $.post(url, 
           { tech_id: $(this).attr('data-id'), hours: $(this).val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTable()
     )
  )

#
# Equipment
#
$('#add-equipment')
  .live('click', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_equipment'
    $.post(url, 
           { eq_id: $('#new_eq_id').val(), hours: $('#new_eq_hours').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadEquipmentTable()
     )
   )

reloadEquipmentTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/equipment_table'
  $.get(url, {}, (html) ->
    $('#equipment').empty().html(html)
    updateGrandTotal()
  )


$('#equipment .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".equipment-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#equipment#{tech_id}").remove()
    reloadEquipmentTable()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.eq_hours')
  .live('change', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_eq_hours'
    $.post(url, 
          { eq_id: $(this).attr('data-id'), hours: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadEquipmentTable()
    )
  )


#
# Materials
#
$('#add-material')
  .live('click', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_material'
    $.post(url, 
           { mat_id: $('#new_mat_id').val(), quantity: $('#new_mat_qty').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadMaterialTable()
     )
   )

reloadMaterialTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/materials_table'
  $.get(url, {}, (html) ->
    $('#materials').empty().html(html)
    updateGrandTotal()
  )


$('#materials .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".material-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#material#{tech_id}").remove()
    reloadMaterialTable()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.mat_qty')
  .live('change', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_mat_qty'
    $.post(url, 
          { mat_id: $(this).attr('data-id'), quantity: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadMaterialTable()
    )
  )

#
# Others
#
$('#add-other')
  .live('click', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_other'
    $.post(url, 
           { other_type_id: $('#new_other_type').val(), concept: $('#new_other_concept').val(), price: $('#new_other_price').val() }, 
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadOthersTable()
     )
   )

reloadOthersTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/others_table'
  $.get(url, {}, (html) ->
    $('#others').empty().html(html)
    updateGrandTotal()
  )


$('#others .close')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $(".other-row").removeClass('error')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    other_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#others#{other_id}").remove()
    reloadOthersTable()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$('.other_price')
  .live('change', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_other_price'
    $.post(url, 
          { other_id: $(this).attr('data-id'), price: $(this).val() }, 
          (xhr) ->
            res = $.parseJSON(xhr)
            showFlash(res['flash']['notice'], 'success')
            reloadOthersTable()
    )
  )



#----------------
# LAB ADMIN USERS 
#----------------
$('.admin-users')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin_members'
    setHash('#!' + url, false)
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    alert('Error')
  )

$('#admin_lab_member_access')
  .live('change', () ->
    adminLabMembersLiveSearch()
  )

$('#admin-lab-members-search-box')
  .live('keyup', () ->
    adminLabMembersLiveSearch()
  )


@adminLabMembersLiveSearch = adminLabMembersLiveSearch = () ->
  $("#admin-lab-members-search-box").addClass("loading")
  form = $("#admin-lab-members-live-search")
  lab_id = form.attr('lab_id')
  url = "/laboratory/#{lab_id}/admin_lab_members_live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#admin-lab-members-search-box").removeClass("loading")
    $("#admin-lab-members-list").empty().html(html)
    $("#admin-lab-members-list .admin-lab-member-item:first").click()
  )

$('.admin-lab-member-item')
  .live('click', () ->
    $('.admin-lab-member-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/laboratory_members/' + $(this).attr('laboratory_member_id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-member-details').html(html)
    )
  )

$('#edit-laboratory-member-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#add-new-member-button')
  .live('click', () ->
    url = '/laboratory/' + $(this).attr('lab_id') + '/new_member'
    $.get(url, {}, (html) ->
      $('#admin-member-details').empty().html(html)
    )
  )

$('#new-laboratory-member-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-members-search-box').val(res['name'])
    adminLabMembersLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#--------------------
# LAB ADMIN EQUIPMENT 
#--------------------
$('.admin-equipment')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    lab_id = $(this).attr('data-laboratory-id')
    url = '/laboratory/' + lab_id + '/admin_equipment'
    setHash('#!' + url, false)
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    alert('Error')
  )

$('#admin-lab-equipment-search-box')
  .live('keyup', () ->
    adminLabEquipmentLiveSearch()
  )


@adminLabEquipmentLiveSearch = adminLabEquipmentLiveSearch = () ->
  $("#admin-lab-equipment-search-box").addClass("loading")
  form = $("#admin-lab-equipment-live-search")
  lab_id = form.attr('data-laboratory-id')
  url = "/laboratory/#{lab_id}/admin_lab_equipment_live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#admin-lab-equipment-search-box").removeClass("loading")
    $("#admin-lab-equipment-list").empty().html(html)
    $("#admin-lab-equipment-list .admin-lab-equipment-item:first").click()
  )

$('.admin-lab-equipment-item')
  .live('click', () ->
    $('.admin-lab-equipment-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/equipment/' + $(this).attr('data-equipment-id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-equipment-details').html(html)
    )
  )

$('#edit-equipment-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    id = res['id']
    $('#equipment_name_' + id).html(res['name'])
    $('#equipment_lab_' + id).html(res['laboratory'])
    showFlash(res['flash']['notice'], 'success')
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#add-new-equipment-button')
  .live('click', () ->
    url = '/laboratory/' + $(this).attr('data-laboratory-id') + '/new_equipment'
    $.get(url, {}, (html) ->
      $('#admin-equipment-details').empty().html(html)
    )
  )

$('#new-laboratory-equipment-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-equipment-search-box').val(res['name'])
    adminLabEquipmentLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#------------------
# ADMINISTRATION
#------------------
$(document).on("click", "#admin-nav li", () ->
  url = $(this).attr('data-link')
  $("#admin-nav li").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#admin-main-panel').empty().html(html)
  )
)

#
# Clients
#
@ClientsLiveSearch = ClientsLiveSearch = () ->
  form = $("#clients-live-search")
  url = "/clients/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#clients-list").empty().html(html)
    $("#clients-list .client-item:first").click()
  )

$(document).on("change", '#client_type', () ->
  ClientsLiveSearch()
)

$('#clients-search-box')
  .live('keyup', () ->
    ClientsLiveSearch()
  )

$(document).on("click", ".client-item", () ->
  id = $(this).attr('data-id')
  url = '/clients/' + id
  $(".client-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#client-details').empty().html(html)
  )
)

$(document).on("click", "#sync-clients", () ->
  alert('En fase de planeación')
)

#
# Equipment
#
@EquipmentLiveSearch = EquipmentLiveSearch = () ->
  form = $("#equipment-live-search")
  url = "/equipment/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#equipment-list").empty().html(html)
    $("#equipment-list .equipment-item:first").click()
  )

$(document).on("change", '#search_laboratory_id', () ->
  EquipmentLiveSearch()
)

$('#equipment-search-box')
  .live('keyup', () ->
    EquipmentLiveSearch()
  )

$(document).on("click", ".equipment-item", () ->
  id = $(this).attr('data-id')
  url = '/equipment/' + id + '/edit'
  $(".equipment-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#equipment-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-equipment-button", () ->
  url = '/equipment/new'
  $.get(url, {}, (html) ->
    $('#equipment-details').empty().html(html)
  )
)

$('#new-equipment-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#equipment-search-box').val(res['name'])
    EquipmentLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#
# Materials
#

@MaterialsLiveSearch = MaterialsLiveSearch = () ->
  form = $("#materials-live-search")
  url = "/materials/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#materials-list").empty().html(html)
    $("#materials-list .material-item:first").click()
  )

$(document).on("change", '#search_laboratory_id', () ->
  MaterialsLiveSearch()
)

$('#search_unit_id')
  .live('change', () ->
    MaterialsLiveSearch()
  )

$('#materials-search-box')
  .live('keyup', () ->
    MaterialsLiveSearch()
  )

$(document).on("click", ".material-item", () ->
  id = $(this).attr('data-id')
  url = '/materials/' + id + '/edit'
  $(".material-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#materials-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-materials-button", () ->
  url = '/materials/new'
  $.get(url, {}, (html) ->
    $('#materials-details').empty().html(html)
  )
)

$('#new-material-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#materials-search-box').val(res['name'])
    MaterialsLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#edit-material-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#material_display_' + res['id']).html(res['display'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#
# Laboratories
#

@AdminLaboratoriesLiveSearch = AdminLaboratoriesLiveSearch = () ->
  form = $("#laboratories-live-search")
  url = "/laboratories/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#laboratories-list").empty().html(html)
    $("#laboratories-list .laboratories-item:first").click()
  )

$(document).on("change", '#search_laboratory_id', () ->
  AdminLaboratoriesLiveSearch()
)

$('#search_unit_id')
  .live('change', () ->
    AdminLaboratoriesLiveSearch()
  )

$('#laboratories-search-box')
  .live('keyup', () ->
    AdminLaboratoriesLiveSearch()
  )

$(document).on("click", ".laboratories-item", () ->
  id = $(this).attr('data-id')
  url = '/laboratories/' + id + '/edit'
  $(".laboratories-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#laboratory-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-laboratory-button", () ->
  url = '/laboratories/new'
  $.get(url, {}, (html) ->
    $('#laboratory-details').empty().html(html)
  )
)

$('#new-laboratory-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#laboratories-search-box').val(res['name'])
    AdminLaboratoriesLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#edit-laboratory-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#material_display_' + res['id']).html(res['display'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#
# Users
#

@AdminUsersLiveSearch = AdminUsersLiveSearch = () ->
  form = $("#users-live-search")
  url = "/users/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#users-list").empty().html(html)
    $("#users-list .user-item:first").click()
  )

$(document).on("change", '#search_user_id', () ->
  AdminUsersLiveSearch()
)

$('#search_user_type')
  .live('change', () ->
    AdminUsersLiveSearch()
  )

$('#users-search-box')
  .live('keyup', () ->
    AdminUsersLiveSearch()
  )

$(document).on("click", ".user-item", () ->
  id = $(this).attr('data-id')
  url = '/users/' + id + '/edit'
  $(".user-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#user-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-user-button", () ->
  url = '/users/new'
  $.get(url, {}, (html) ->
    $('#user-details').empty().html(html)
  )
)

$('#new-user-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#users-search-box').val(res['name'])
    AdminUsersLiveSearch()
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$('#edit-user-form')
  .live("ajax:beforeSend", (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.with-errors').removeClass('with-errors')
  )
  .live("ajax:success", (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#user_name_' + res['id']).html(res['name'])
  )
  .live('ajax:complete', (evt, xhr, status) ->
  )
  .live("ajax:error", (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#-------
# ERRORS
#-------
@showFormErrors = showFormErrors = (xhr, status, error) ->
  try 
    res = $.parseJSON(xhr.responseText)
  catch err
    res['errors'] = { generic_error: "Error:" + err.description }

  showFlash(res['flash']['error'], 'error')

  for e in res['errors']  
    errorMsg = $('<div>' + res['errors'][e] + '</div>').addClass('error-message')
    $('#field_' + model_name + '_' + e.replace('.', '_')).addClass('with-errors').append(errorMsg)
  

@showFlash = showFlash = (msg, type) ->
  $("#flash-notice").remove()
  $('body').append('<div id="flash-notice" class="alert"></div>')
  $("#flash-notice").addClass('alert-' + type).html(msg)
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

hashTimer = setInterval(checkHash, 1000)

$('#folders-link')
  .live('click' , () ->
    window.location = '/#!/folders'
    checkHash()
  )



