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

#-------
# COSTS
#-------

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

#------------------
# CUSTOMER SERVICE
#------------------
$(document).on("click", "#customer-service-nav li", () ->
  url = $(this).attr('data-link')
  $("#customer-service-nav li").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#customer-service-main-panel').empty().html(html)
  )
)

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



