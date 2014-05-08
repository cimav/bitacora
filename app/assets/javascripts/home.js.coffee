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
    $('#folders').empty().html(html)
  )
$(document).on('change', '#folder_filter', () ->
  foldersLiveSearch()
)
$(document).on('keyup', '#search-box', () ->
  foldersLiveSearch()
)
$(document).on('click', '#search-box', () ->
  foldersLiveSearch()
)

$(document).on('click', '.service-request-item', () ->
    getServiceRequest($(this).attr('service_request_id'))
  )


$(document).on('click', '#add-new-folder-button', () ->
    url = '/service_requests/new'
    $.get(url, {}, (html) ->
      $('#workarea').empty().html(html)
    )
  )

@getServiceRequest = getServiceRequest = (id) ->
  url = '/service_requests/' + id
  $.get(url, {}, (html) ->
    current_request = id
    $('#workarea').empty().html(html)
    setHash('#!' + url, false)
  )

$(document).on('click', '.requested-service-link', () ->
    id = $(this).data('id')
    sample_id = $(this).data('sample-id')
    getRequestedService(sample_id, id) 
  )

newSampleDialog = () ->
  url = '/samples/new_dialog/' + current_request
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )

$(document).on('click', '#add-new-sample-button', () ->
    current_request = $(this).data('id')
    newSampleDialog()
  )

addServiceDialog = (from_id = false) ->
  url = "/laboratory_services/add_service_dialog/?from_id=#{from_id}"
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
    labServicesLiveSearch()
  )

$(document).on('click', '.add-service-link', () ->
    current_sample = $(this).data('sample-id')
    addServiceDialog()
  )

$(document).on('click', '#open-add-service-by-lab-modal', () ->
    current_sample = $('#open-add-service-by-lab-modal').attr('data-for-sample')
    addServiceDialog($('#open-add-service-by-lab-modal').attr('data-from-id'))
  )

$(document).on('click', '#service_type', () ->
    labServicesLiveSearch()
  )

$(document).on('change', '#laboratory', () ->
    labServicesLiveSearch()
  )

$(document).on('keyup', '#laboratory-services-search-box', () ->
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

$(document).on('click', '.lab-service-item', () ->
    $('.lab-service-item').removeClass('selected')
    $(this).addClass('selected')
    from_id = $(this).attr('data-from-id')
    url = '/laboratory_services/' + $(this).attr('laboratory_service_id') + '/for_sample/' + current_sample + '?from_id=' + from_id
    $.get(url, {}, (html) ->
      $('#service-details').html(html)
    )
  )

$(document).on('click', '#add-service-modal-submit', () ->
    $('#new-requested-service-form').submit();
  )

$(document).on('ajax:beforeSend', '#new-requested-service-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )

$(document).on('ajax:success', '#new-requested-service-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#add-service-modal').modal('hide').remove()
    if (res['from_lab'])
      getRequestedService(res['sample_id'], res['from_id'])
    else
      getSampleRequestedServices(res['sample_id'])
      getRequestedService(res['sample_id'], res['id'])
  )

$(document).on('ajax:error', '#new-requested-service-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

@getRequestedService = getRequestedService = (sample_id, id) ->
  current_sample = sample_id
  url = '/samples/' + sample_id + '/requested_services/' + id
  current_requested_service = id
  $.get(url, {}, (html) ->
    $('.requested-service-link').removeClass('active')
    $('#requested-service-link-' + id).addClass('active')
    $('#folder-work-panel').empty().html(html)
  )

getSampleRequestedServices = (sample_id) ->
  url = '/samples/' + sample_id + '/requested_services_list'
  $.get(url, {}, (html) ->
    $('#sample-' + sample_id + '-services').empty().html(html)
  )

$(document).on('click', '.requested_service', () ->
    getRequestedService($(this).attr('sample_id'), $(this).attr('requested_service_id'))
  )

$(document).on('ajax:beforeSend', '#new-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getServiceRequest(res['service_request_id'])
  )
$(document).on('ajax:error', '#new-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


$(document).on('ajax:beforeSend', '#new-request-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-request-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#search-filter').val('*')
    $('#search-box').val(res['number'])
    foldersLiveSearch()
    #getServiceRequest(res['id'])
  )
$(document).on('ajax:error', '#new-request-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#-----------
# LABORATORY
#-----------
current_requestor = 0
@labReqServicesLiveSearch = labReqServicesLiveSearch = () ->
  $("#lab-req-serv-search-box").addClass("loading")
  form = $("#lab-req-serv-live-search")
  url = '/laboratory/' + form.attr('laboratory_id')  + '/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#lab-req-serv-search-box").removeClass("loading")
    $("#lab-req-serv-panel .items-placeholder").empty().html(html)
    $("#lab-req-serv-panel .items-placeholder .lab-req-serv-item:first").click()
    current_requestor = 1
    $('#req-serv-items').bind('scroll', () ->
      cur_req = $("#requestor_#{current_requestor}")
      next_req = $("#requestor_#{current_requestor + 1}")
      if (cur_req.offset().top > $('#req-serv-items').offset().top + 20)
        current_requestor -= 2
        if current_requestor <= 1
          current_requestor = 1
          $('#current-requestor').html($("#requestor_1").html())
      if (next_req.offset().top < $('#req-serv-items').offset().top + 20)
        current_requestor += 1
        $('#current-requestor').html(next_req.html())


    )
  )

$(document).on('change', '#lrs_status', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_requestor', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_assigned_to', () ->
    labReqServicesLiveSearch()
  )

$(document).on('keyup', '#req-serv-search-box', () ->
    $('#req-serv-items').scroll()
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

$(document).on('ajax:beforeSend', '#new-activity-log-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )

$(document).on('ajax:success', '#new-activity-log-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getActivityLog(res['id'])
  )

$(document).on('ajax:error', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#--------
# ACTIONS
#--------

updateIcon = (id, status_class, icon_class) ->
  $item = $('#requested-service-link-' + id + ' .icon')
  $item.removeClass()
  $item.addClass('icon')
  $item.addClass(status_class)
  $item.html('<span class="glyphicon ' + icon_class + '"></span>')

# OWNER AUTH
$(document).on('click', '#change_status_owner_auth', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/owner_auth_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#owner-auth-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#owner-auth-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#owner-auth-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


# SUP AUTH
$(document).on('click', '#change_status_sup_auth', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/sup_auth_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#sup-auth-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#sup-auth-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#sup-auth-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# SEND QUOTE
$(document).on('click', '#change_status_send_quote', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/send_quote_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#send-quote-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#send-quote-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#send-quote-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# INITIAL
$(document).on('click', '#change_status_initial', () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/initial_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#initial-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#initial-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#initial-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# RECEIVED
$(document).on('click', '#change_status_received', () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/receive_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#receive-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )

$(document).on('ajax:success', '#receive-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )

$(document).on('ajax:error', '#receive-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# ASSIGN
$(document).on('click', '#change_status_assigned', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/assign_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )


$(document).on('ajax:beforeSend', '#assign-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#assign-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#assign-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# SUSPEND
$(document).on('click', '#change_status_suspended', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/suspend_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#suspend-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#suspend-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#suspend-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# REINIT
$(document).on('click', '#change_status_reinit', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/reinit_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#reinit-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#reinit-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#reinit-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# START
$(document).on('click', '#change_status_in_progress', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/start_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#start-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#start-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#start-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# FINISH
$(document).on('click', '#change_status_finished', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/finish_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#finish-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#finish-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#finish-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

# CANCEL
$(document).on('click', '#change_status_canceled', () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/cancel_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#cancel-sample-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#cancel-sample-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['sample_id'], res['id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )

$(document).on('ajax:error', '#cancel-sample-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )



#-----------
# NAVIGATION
#-----------
$(document).on('click', '#nav-home', () ->
    url = '/home'
    setHash('#!/home', true)
    $('.nav-item').removeClass('selected')
    $('#nav-home').addClass('selected')
  )

$(document).on('click', '#nav-my-requests', () ->
    url = '/my-requests'
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-my-requests').addClass('selected')
  )

$(document).on('click', '.nav-lab', () ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-laboratory-' + lab_id).addClass('selected')
  )

#----------
# LAB ADMIN
#----------

$(document).on('ajax:beforeSend', '.admin-lab', (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin'
    setHash('#!' + url, false)
  )
$(document).on('ajax:success', '.admin-lab', (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )

$(document).on('ajax:error', '.admin-lab', (evt, xhr, status, error) ->
    alert('Error')
  )


$(document).on('ajax:beforeSend', '#edit-laboratory-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )

$(document).on('ajax:success', '#edit-laboratory-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $("#nav-title-#{res['id']}").html(res['name'])
    $("#laboratory-bar h2").html(res['name'])
  )

$(document).on('ajax:error', '#edit-laboratory-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#-------------------
# LAB ADMIN SERVICES
#-------------------
$(document).on('ajax:beforeSend', '.admin-services', (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin_services'
    setHash('#!' + url, false)
  )
$(document).on('ajax:success', '.admin-services', (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )

$(document).on('ajax:error', '.admin-services', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('change', '#admin_lab_service_type', () ->
    adminLabServicesLiveSearch()
  )

$(document).on('keyup', '#admin-lab-services-search-box', () ->
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

$(document).on('click', '.admin-lab-service-item', () ->
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

$(document).on('ajax:beforeSend', '#edit-laboratory-service-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-laboratory-service-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#edit-laboratory-service-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('click', '#add-new-service-button', () ->
    url = '/laboratory/' + $(this).attr('lab_id') + '/new_service'
    $.get(url, {}, (html) ->
      $('#admin-service-details').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#new-laboratory-service-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-laboratory-service-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-services-search-box').val(res['name'])
    adminLabServicesLiveSearch()
  )

$(document).on('ajax:error', '#new-laboratory-service-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#
# Technicians template
#
$(document).on('click', '#add-technician-template', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_technician'
    $.post(url,
           { user_id: $('#new_tech_user_id').val(), participation: $('#new_tech_participation').val(), hours: $('#new_tech_hours').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTableTemplate()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
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

$(document).on('ajax:beforeSend', '#technicians-template .close', (evt, xhr, settings) ->
    $(".technician-row").removeClass('error')
  )
$(document).on('ajax:success', '#technicians-template .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#technician_row_#{tech_id}").remove()
    reloadTechniciansTableTemplate()
  )

$(document).on('ajax:error', '#technicians-template .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )

$(document).on('change', '.tech_participation_template', () ->
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


$(document).on('click', '.tech_hours_template', () ->
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
$(document).on('click', '#add-equipment-template', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_equipment'
    $.post(url,
           { eq_id: $('#new_eq_id').val(), hours: $('#new_eq_hours').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadEquipmentTableTemplate()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadEquipmentTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/equipment_table'
  $.get(url, {}, (html) ->
    $('#equipment-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$(document).on('ajax:beforeSend', '#equipment-template .close', (evt, xhr, settings) ->
    $(".equipment-row").removeClass('error')
  )
$(document).on('ajax:success', '#equipment-template .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    eq_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#equipment#{eq_id}").remove()
    reloadEquipmentTableTemplate()
  )

$(document).on('ajax:error', '#equipment-template .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.eq_hours_template', () ->
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
$(document).on('click', '#add-material-template', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_material'
    $.post(url,
           { mat_id: $('#new_mat_id').val(), quantity: $('#new_mat_qty').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadMaterialTableTemplate()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadMaterialTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/materials_table'
  $.get(url, {}, (html) ->
    $('#materials-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$(document).on('ajax:beforeSend', '#materials-template .close', (evt, xhr, settings) ->
    $(".material-row").removeClass('error')
  )
$(document).on('ajax:success', '#materials-template .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    mat_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#material#{mat_id}").remove()
    reloadMaterialTableTemplate()
  )

$(document).on('ajax:error', '#materials-template .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.mat_qty_template', () ->
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
$(document).on('click', '#add-other-template', () ->
    laboratory_service = $('#laboratory_service_id').val()
    url = '/laboratory_services/' + laboratory_service + '/new_other'
    $.post(url,
           { other_type_id: $('#new_other_type').val(), concept: $('#new_other_concept').val(), price: $('#new_other_price').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadOthersTableTemplate()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadOthersTableTemplate = () ->
  laboratory_service = $('#laboratory_service_id').val()
  url = '/laboratory_services/' + laboratory_service + '/others_table'
  $.get(url, {}, (html) ->
    $('#others-template').empty().html(html)
    updateGrandTotalTemplate(laboratory_service)
  )


$(document).on('ajax:beforeSend', '#others-template .close', (evt, xhr, settings) ->
    $(".other-row").removeClass('error')
  )
$(document).on('ajax:success', '#others-template .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    other_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#others#{other_id}").remove()
    reloadOthersTableTemplate()
  )

$(document).on('ajax:error', '#others-template .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.other_price_template', () ->
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

$(document).on('click', '#add-technician', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_technician'
    $.post(url,
           { user_id: $('#new_tech_user_id').val(), participation: $('#new_tech_participation').val(), hours: $('#new_tech_hours').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTable()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadTechniciansTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/technicians_table'
  $.get(url, {}, (html) ->
    $('#technicians').empty().html(html)
    updateGrandTotal()
  )


$(document).on('ajax:beforeSend', '#technicians .close', (evt, xhr, settings) ->
    $(".technician-row").removeClass('error')
  )
$(document).on('ajax:success', '#technicians .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#technician_row_#{tech_id}").remove()
    reloadTechniciansTable()
  )

$(document).on('ajax:error', '#technicians .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )

$(document).on('change', '.tech_participation', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/update_participation'
    $.post(url,
           { tech_id: $(this).attr('data-id'), participation: $(this).val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadTechniciansTable()
     )
  )


$(document).on('change', '.tech_hours', () ->
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
$(document).on('click', '#add-equipment', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_equipment'
    $.post(url,
           { eq_id: $('#new_eq_id').val(), hours: $('#new_eq_hours').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadEquipmentTable()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadEquipmentTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/equipment_table'
  $.get(url, {}, (html) ->
    $('#equipment').empty().html(html)
    updateGrandTotal()
  )


$(document).on('ajax:beforeSend', '#equipment .close', (evt, xhr, settings) ->
    $(".equipment-row").removeClass('error')
  )
$(document).on('ajax:success', '#equipment .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#equipment#{tech_id}").remove()
    reloadEquipmentTable()
  )

$(document).on('ajax:error', '#equipment .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.eq_hours', () ->
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
$(document).on('click', '#add-material', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_material'
    $.post(url,
           { mat_id: $('#new_mat_id').val(), quantity: $('#new_mat_qty').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadMaterialTable()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadMaterialTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/materials_table'
  $.get(url, {}, (html) ->
    $('#materials').empty().html(html)
    updateGrandTotal()
  )


$(document).on('ajax:beforeSend', '#materials .close', (evt, xhr, settings) ->
    $(".material-row").removeClass('error')
  )
$(document).on('ajax:success', '#materials .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    tech_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#material#{tech_id}").remove()
    reloadMaterialTable()
  )

$(document).on('ajax:error', '#materials .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.mat_qty', () ->
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
$(document).on('click', '#add-other', () ->
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/new_other'
    $.post(url,
           { other_type_id: $('#new_other_type').val(), concept: $('#new_other_concept').val(), price: $('#new_other_price').val() },
           (xhr) ->
             res = $.parseJSON(xhr)
             showFlash(res['flash']['notice'], 'success')
             reloadOthersTable()
     )
     .fail( (data) ->
       res = $.parseJSON(data.responseText)
       showFlash(res['flash']['error'], 'alert-error')
     )
   )

reloadOthersTable = () ->
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/others_table'
  $.get(url, {}, (html) ->
    $('#others').empty().html(html)
    updateGrandTotal()
  )


$('#others .close')
$(document).on('ajax:beforeSend', '#others .close', (evt, xhr, settings) ->
    $(".other-row").removeClass('error')
  )
$(document).on('ajax:success', '#others .close', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    other_id = res['id']
    showFlash(res['flash']['notice'], 'alert-success')
    $("#others#{other_id}").remove()
    reloadOthersTable()
  )

$(document).on('ajax:error', '#others .close', (evt, xhr, status, error) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['error'], 'alert-error')
  )


$(document).on('change', '.other_price', () ->
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
$(document).on('ajax:beforeSend', '.admin-users', (evt, xhr, settings) ->
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin_members'
    setHash('#!' + url, false)
  )
$(document).on('ajax:success', '.admin-users', (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )

$(document).on('ajax:error', '.admin-users', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('change', '#admin_lab_member_access', () ->
    adminLabMembersLiveSearch()
  )

$(document).on('keyup', '#admin-lab-members-search-box', () ->
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

$(document).on('click', '.admin-lab-member-item', () ->
    $('.admin-lab-member-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/laboratory_members/' + $(this).attr('laboratory_member_id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-member-details').html(html)
    )
  )

$(document).on('ajax:beforeSend', '#edit-laboratory-member-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-laboratory-member-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#edit-laboratory-member-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('click', '#add-new-member-button', () ->
    url = '/laboratory/' + $(this).attr('lab_id') + '/new_member'
    $.get(url, {}, (html) ->
      $('#admin-member-details').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#new-laboratory-member-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-laboratory-member-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-members-search-box').val(res['name'])
    adminLabMembersLiveSearch()
  )

$(document).on('ajax:error', '#new-laboratory-member-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#--------------------
# LAB ADMIN EQUIPMENT
#--------------------
$(document).on('ajax:beforeSend', '.admin-equipment', (evt, xhr, settings) ->
    lab_id = $(this).attr('data-laboratory-id')
    url = '/laboratory/' + lab_id + '/admin_equipment'
    setHash('#!' + url, false)
  )
$(document).on('ajax:success', '.admin-equipment', (evt, data, status, xhr) ->
    $('#laboratory-workarea').empty().html(data)
  )

$(document).on('ajax:error', '.admin-equipment', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('keyup', '#admin-lab-equipment-search-box', () ->
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

$(document).on('click', '.admin-lab-equipment-item', () ->
    $('.admin-lab-equipment-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/equipment/' + $(this).attr('data-equipment-id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-equipment-details').html(html)
    )
  )

$(document).on('ajax:beforeSend', '#edit-equipment-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-equipment-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    id = res['id']
    $('#equipment_name_' + id).html(res['name'])
    $('#equipment_lab_' + id).html(res['laboratory'])
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#edit-equipment-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('click', '#add-new-equipment-button', () ->
    url = '/laboratory/' + $(this).attr('data-laboratory-id') + '/new_equipment'
    $.get(url, {}, (html) ->
      $('#admin-equipment-details').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#new-laboratory-equipment-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-laboratory-equipment-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-equipment-search-box').val(res['name'])
    adminLabEquipmentLiveSearch()
  )

$(document).on('ajax:error', '#new-laboratory-equipment-form', (evt, xhr, status, error) ->
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

$(document).on("keyup", '#clients-search-box', () ->
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

$(document).on('keyup', #equipment-search-box', () ->
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

$(document).on('ajax:beforeSend', '#new-equipment-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-equipment-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#equipment-search-box').val(res['name'])
    EquipmentLiveSearch()
  )
$(document).on('ajax:error', '#new-equipment-form', (evt, xhr, status, error) ->
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

$(document).on('change', '#search_unit_id', () ->
    MaterialsLiveSearch()
  )

$(document).on('keyup', '#materials-search-box', () ->
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

$(document).on('ajax:beforeSend', '#new-material-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-material-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#materials-search-box').val(res['name'])
    MaterialsLiveSearch()
  )

$(document).on('ajax:error', '#new-material-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-material-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-material-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#material_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-material-form', (evt, xhr, status, error) ->
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

$(document).on('change', '#search_unit_id', () ->
    AdminLaboratoriesLiveSearch()
  )

$(document).on('keyup', '#laboratories-search-box', () ->
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

$(document).on('ajax:beforeSend', '#new-laboratory-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-laboratory-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#laboratories-search-box').val(res['name'])
    AdminLaboratoriesLiveSearch()
  )

$(document).on('ajax:error', '#new-laboratory-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-laboratory-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-laboratory-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#material_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-laboratory-form', (evt, xhr, status, error) ->
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

$(document).on("change", '#search_business_unit_id', () ->
  AdminUsersLiveSearch()
)

$(document).on("change", '#search_user_id', () ->
  AdminUsersLiveSearch()
)

$(document).on('change', '#search_user_type', () ->
    AdminUsersLiveSearch()
  )

$(document).on('keyup', '#users-search-box', () ->
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

$(document).on('ajax:beforeSend', '#new-user-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-user-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#users-search-box').val(res['name'])
    AdminUsersLiveSearch()
  )

$(document).on('ajax:error', '#new-user-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-user-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-user-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#user_name_' + res['id']).html(res['name'])
  )

$(document).on('ajax:error', '#edit-user-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#---------------------------------------
# Search folder/sample/requested_service
#---------------------------------------
@folderGo = folderGo = (folder_number,sample_number ,requested_service_id) ->
  form = $('#folder-live-search')
  $("#search-box").val(folder_number)
  url = '/service_requests/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $('#folder-panel .items-placeholder').empty().html(html)
    url = '/service_requests/' + folder_number
    $.get(url, {}, (html) ->
      $("#" + folder_number).addClass('selected')
      current_request = folder_number
      $('#folder-main-panel').empty().html(html)
      setTimeout ->
        sample_id = $("#" + sample_number).attr("sample_id")
        url = '/samples/' + sample_id
        current_sample = sample_id
        $.get(url, {}, (html) ->
          $('#no-samples').remove()
          $('#request-workarea').empty().html(html)
          setTimeout ->
            $("#requested_service_" + requested_service_id).click()
          , 500
        )
      , 500
    )
  )

#---------------------
# New material dialog
#---------------------
$(document).on('click', '#new-material-link', () ->
    $("#new-material-dialog").remove()
    $('body').append('<div id="new-material-dialog"></div>')
    url = '/materials/new_dialog'
    $.get(url, {}, (html) ->
      $('#new-material-dialog').empty().html(html)
      $('#new-material-modal').modal({ keyboard:true, backdrop:true, show: true });
    )
  )

$(document).on('ajax:beforeSend', '#new-material-dialog-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-material-dialog-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#new-material-modal').modal('hide').remove()
    $("#new_mat_id").append("<option value=#{res['id']}>#{res['name']}</option>")
    # TODO: Locate new material and focus on qty
  )

$(document).on('ajax:error', '#new-material-dialog-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

#--------------------
# Edit folder dialog
#--------------------
$(document).on('click', '#edit-service-request-link', () ->
    $("#edit-service-request-dialog").remove()
    $('body').append('<div id="edit-service-request-dialog"></div>')
    id = $(this).data('id')
    url = "/service_requests/edit_dialog/#{id}"
    $.get(url, {}, (html) ->
      $('#edit-service-request-dialog').empty().html(html)
      $('#edit-service-request-modal').modal({ keyboard:true, backdrop:true, show: true });
    )
  )

$(document).on('ajax:beforeSend', '#edit-service-request-dialog-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-service-request-dialog-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#edit-service-request-modal').modal('hide').remove()
    $("#new_mat_id").append("<option value=#{res['id']}>#{res['name']}</option>")
    # TODO: Locate new material and focus on qty
  )

$(document).on('ajax:error', '#edit-service-request-dialog-form', (evt, xhr, status, error) ->
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
    $('#field_' + model_name + '_' + e.replace('.', '_')).addClass('has-errors').append(errorMsg)


@showFlash = showFlash = (msg, type) ->
  $("#flash-notice").remove()
  $('body').append('<div id="flash-notice" class="alert"></div>')
  $("#flash-notice").addClass('alert-' + type).html(msg)
  $("#flash-notice").slideDown()
  $("#flash-notice").delay(1500).slideUp() if (type != 'error')


#--------------------
# Active sidenav link
#--------------------
@activeSideNav = activeSideNav = (option) ->
  $('#sidenav .active').removeClass('active');
  $(option).parent().addClass('active');

#--------------
# LOCATION HASH
#--------------
setHash = (h, get_url) ->
  hash = h
  window.location.hash = hash
  checkHash() if get_url

@checkHash = checkHash = () ->
  if window.location.hash != hash
    hash = window.location.hash
    if (hash.slice(0, 2) == '#!' && hash.length > 3)
      if hash.indexOf("?") != -1
        from_url = "&__from__=url"
      else
        from_url = "?__from__=url"
      url = hash.slice(2 - hash.length) + from_url
      $.get(url, {}, (html) ->
        $('#workarea').empty().html(html)
      )

hashTimer = setInterval(checkHash, 1000)

$(document).on("click", "#folders-link", () ->
  window.location = '/#!/folders'
  checkHash()
)
