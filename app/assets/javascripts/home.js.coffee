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

$(document).on('click', '.service-request-link', () ->
    getServiceRequest($(this).data('id'))
  )

$(document).on('click', '#add-new-folder-button', () ->
    $(this).prop('disabled', true)
    setHash('#!/folders/new', true)
  )

@getServiceRequestActions = getServiceRequestActions = (id) ->
  url = '/service_requests/' + id + '/actions'
  $.get(url, {}, (html) ->
    $('#folder-actions').empty().html(html)
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
    getRequestedService(id) 
  )

newSampleDialog = () ->
  url = '/samples/new_dialog/' + current_request
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )

$(document).on('click', '#add-new-sample-button', () ->
    $(this).prop('disabled', true)
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
    $(this).prop('disabled', true)
    current_sample = $(this).data('sample-id')
    addServiceDialog()
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


$(document).on('ajax:beforeSend', '#new-requested-service-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )

$(document).on('ajax:success', '#new-requested-service-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getSampleRequestedServices(res['sample_id'])
    getServiceRequestActions(res['service_request_id'])
    if (res['from_lab'])
      getRequestedService(res['from_id'])
    else
      getRequestedService(res['id'])
  )

$(document).on('ajax:error', '#new-requested-service-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

@getRequestedService = getRequestedService = (id) ->
  #current_sample = sample_id
  url = '/requested_services/' + id
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
    getRequestedService($(this).attr('requested_service_id'))
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
    getServiceRequest(res['id'])
  )
$(document).on('ajax:error', '#new-request-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
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
    $("#new-activity-log-form").find('input, textarea, button, select').prop("disabled", true)
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')

  )

$(document).on('ajax:success', '#new-activity-log-form', (evt, data, status, xhr) ->
    $form = $(this)
    $("#new-activity-log-form").find('input, textarea, button, select').prop("disabled", false)
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


# STATUS FORM ACTIONS
$(document).on('ajax:beforeSend', '#status-form', (evt, xhr, settings) ->
    $("#status-form").find('input, textarea, button, select').prop("disabled", true)
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#status-form', (evt, data, status, xhr) ->
    $form = $(this)
    $("#status-form").find('input, textarea, button, select').prop("disabled", false)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getRequestedService(res['id'])
    getServiceRequestActions(res['service_request_id'])
    updateIcon(res['id'], res['status_class'], res['icon_class'])
  )
$(document).on('ajax:error', '#status-form', (evt, xhr, status, error) ->
    $("#status-form").find('input, textarea, button, select').prop("disabled", false)
    showFormErrors(xhr, status, error)
  )

# OWNER AUTH
$(document).on('click', '#change_status_owner_auth', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/owner_auth_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# SUP AUTH
$(document).on('click', '#change_status_sup_auth', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/sup_auth_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# SEND QUOTE
$(document).on('click', '#change_status_send_quote', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/send_quote_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# INITIAL
$(document).on('click', '#change_status_initial', () ->
  $(this).prop('disabled', true)
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/initial_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

# RECEIVED
$(document).on('click', '#change_status_received', () ->
  $(this).prop('disabled', true)
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/receive_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

# ASSIGN
$(document).on('click', '#change_status_assigned', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/assign_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# SUSPEND
$(document).on('click', '#change_status_suspended', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/suspend_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# REINIT
$(document).on('click', '#change_status_reinit', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/reinit_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# START
$(document).on('click', '#change_status_in_progress', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/start_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# FINISH
$(document).on('click', '#change_status_finished', () ->
    $(this).prop('disabled', true)
    url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/finish_dialog'
    $.get(url, {}, (html) ->
      $('#folder-work-panel').empty().html(html)
    )
  )

# CANCEL
$(document).on('click', '#change_status_canceled', () ->
  $(this).prop('disabled', true)
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/cancel_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)

# DELETE
$(document).on('click', '#change_status_deleted', () ->
  $(this).prop('disabled', true)
  url = '/samples/' + current_sample + '/requested_services/' + current_requested_service + '/delete_dialog'
  $.get(url, {}, (html) ->
    $('#folder-work-panel').empty().html(html)
  )
)



#-----------
# NAVIGATION
#-----------

$(document).on("click", "#folders-link", () ->
  url = '/#!/folders'
  window.location = url
)

$(document).on('click', '.lab-link', () ->
    lab_id = $(this).data('laboratory_id')
    url = '/laboratory/' + lab_id
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-laboratory-' + lab_id).addClass('selected')
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
    $(this).prop('disabled', true)
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
    $(this).prop('disabled', true)
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
    $(this).prop('disabled', true)
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
    $(this).prop('disabled', true)
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
  $(this).prop('disabled', true)
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
  url = '/laboratory/' + id + '/admin'
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
    folder_id = $("#" + folder_number).attr('service_request_id')
    url = '/service_requests/' + folder_id
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
$(document).on('click', '#edit-service-request-button', () ->
    id = $(this).data('id')
    url = "/service_requests/edit_dialog/#{id}"
    $.get(url, {}, (html) ->
      $('#folder-workarea').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#edit-service-request-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-service-request-form', (evt, data, status, xhr) ->
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    getServiceRequest(res['id'])
  )

$(document).on('ajax:error', '#edit-service-request-form', (evt, xhr, status, error) ->
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
@setHash = setHash = (h, get_url) ->
  window.location.hash = h
  checkHash(get_url) if get_url
  hash = h
  
  

@checkHash = checkHash = (get_url) ->
  if window.location.hash != hash || get_url
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

#--------
# Ready
#--------
$ ->
  $(document).on('keyup keypress', 'form input[type="text"]',(e) ->
    if (e.which == 13)
      e.preventDefault()
      false
  )
  
  $(document).on('keyup keypress', 'form input[type="number"]',(e) ->
    if (e.which == 13)
      e.preventDefault()
      false
  )


