# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@labReqServicesLiveSearch = labReqServicesLiveSearch = () ->
  form = $("#lab-req-serv-live-search")
  url = '/laboratory/' + form.data('laboratory-id')  + '/live_search'
  setHashForLabLiveSearch(form.data('laboratory-id'))
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#lab-req-serv-items").empty().html(html)
  )

setHashForLabLiveSearch = (lab_id) ->
  
  filter = ''
  
  if $('#lrs_status').val() > 0 || $('#lrs_status').val() == '-abiertos' || $('#lrs_status').val() == '-todos'
    filter = filter + "e" + $('#lrs_status').val() + "|" 

  if $('#lrs_requestor').val() > 0
    filter = filter + "s" + $('#lrs_requestor').val() + "|" 

  if $('#lrs_assigned_to').val() > 0
    filter = filter + "a" + $('#lrs_assigned_to').val() + "|" 

  if $('#lrs_type').val() > 0
    filter = filter + "t" + $('#lrs_type').val() + "|" 

  if $('#lrs_client').val() > 0
    filter = filter + "c" + $('#lrs_client').val() + "|" 
  
  if $('#q').val() != ''
    filter = filter + "b" + $('#q').val() + "|" 

  if filter != ''
    setHash('#!/laboratory/' + lab_id + '/f/' + filter, false)
  else
    setHash('#!/laboratory/' + lab_id, false)

$(document).on('change', '#lrs_status', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_requestor', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_client', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_type', () ->
    labReqServicesLiveSearch()
  )

$(document).on('change', '#lrs_assigned_to', () ->
    labReqServicesLiveSearch()
  )

$(document).on('keyup', '#q', () ->
    $('#req-serv-items').scroll()
    window.clearTimeout(window.inlabtimeout)
    window.inlabtimeout = window.setTimeout (-> labReqServicesLiveSearch() ), 500
  )

$(document).on('click', '.lab-req-serv-item', () ->
  lab_id    = $(this).data('laboratory-id')
  id        = $(this).data('requested-service-id')
  number    = $(this).data('number')

  getLabRequestedService(lab_id, id)
)

@getLabRequestedService = getLabRequestedService = (lab_id, id) ->
  setHash('#!/laboratory/' + lab_id + '/s/' + id, true)


#--------------
# LAB REPORTS
#--------------
$(document).on('ajax:beforeSend', '.reports-lab', (evt, xhr, settings) ->
    lab_id = $(this).data('laboratory-id')
    url = '/laboratory/' + lab_id + '/reports'
    setHash('#!/laboratory/' + lab_id + '/reports', false)
  )
$(document).on('ajax:success', '.reports-lab', (evt, data, status, xhr) ->
    $('#lab-work-panel').empty().html(data)
  )

$(document).on('ajax:error', '.reports-lab', (evt, xhr, status, error) ->
    alert('Error')
  )


# General report

$(document).on('ajax:beforeSend', '.reports-general-lab', (evt, xhr, settings) ->
    lab_id = $(this).data('laboratory-id')
    url = '/laboratory/' + lab_id + '/reports_general'
    setHash('#!/laboratory/' + lab_id + '/reports_general', false)
  )
$(document).on('ajax:success', '.reports-general-lab', (evt, data, status, xhr) ->
    $('#lab-report-area').empty().html(data)
  )

$(document).on('ajax:error', '.reports-general-lab', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('click', '#report_general_generate', () ->
    lab_id =  $(this).attr('laboratory_id')
    start_date = $('#start-date').val()
    end_date = $('#end-date').val()
    url = '/laboratory/' + lab_id + '/reports_general?start_date=' + start_date + '&end_date=' + end_date 
    $.get(url, {}, (html) ->
      $('#lab-report-area').empty().html(html)
    )
  )

$(document).on('click', '#report_general_generate_excel', () ->
    lab_id =  $(this).attr('laboratory_id')
    start_date = $('#start-date').val()
    end_date = $('#end-date').val()
    url = '/laboratory/' + lab_id + '/reports_general.xls?start_date=' + start_date + '&end_date=' + end_date 
    window.open(url,"_excel")
  )


#----------
# LAB ADMIN
#----------

$(document).on('ajax:beforeSend', '.admin-lab', (evt, xhr, settings) ->
    lab_id = $(this).data('laboratory-id')
    url = '/laboratory/' + lab_id + '/admin'
  )
$(document).on('ajax:success', '.admin-lab', (evt, data, status, xhr) ->
    $('#lab-work-panel').empty().html(data)
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
    lab_id = $(this).data('laboratory-id')
  )
$(document).on('ajax:success', '.admin-services', (evt, data, status, xhr) ->
    $('#admin-area').empty().html(data)
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
    lab_id =  $(this).attr('laboratory_service_id')
    url = '/laboratory_services/' + $(this).attr('laboratory_service_id') + '/edit'
    $.get(url, {}, (html) ->
      $('#admin-service-workarea').html(html)
      url = '/laboratory_services/' + lab_id + '/edit_cost'
      $.get(url, {}, (html) ->
        $('#admin-service-costs').html(html)
      )
      url = '/laboratory_services/' + lab_id + '/edit_additionals'
      $.get(url, {}, (html) ->
        $('#admin-service-additionals').html(html)
      )
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
      $('#admin-service-workarea').empty().html(html)
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
    $('.grand_total_value').empty().html(html)
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


$(document).on('change', '.tech_hours_template', () ->
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

#----------------
# LAB ADMIN USERS
#----------------
$(document).on('ajax:beforeSend', '.admin-users', (evt, xhr, settings) ->
    lab_id = $(this).data('laboratory-id')
    url = '/laboratory/' + lab_id + '/admin_members'
  )
$(document).on('ajax:success', '.admin-users', (evt, data, status, xhr) ->
    $('#admin-area').empty().html(data)
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
  )
$(document).on('ajax:success', '.admin-equipment', (evt, data, status, xhr) ->
    $('#admin-area').empty().html(data)
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

#----------------------------
# LAB ADMIN CLASSIFICATIONS
#----------------------------
$(document).on('ajax:beforeSend', '.admin-classifications', (evt, xhr, settings) ->
    lab_id = $(this).attr('data-laboratory-id')
    url = '/laboratory/' + lab_id + '/admin_classifications'
  )
$(document).on('ajax:success', '.admin-classifications', (evt, data, status, xhr) ->
    $('#admin-area').empty().html(data)
  )

$(document).on('ajax:error', '.admin-classifications', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('keyup', '#admin-lab-classification-search-box', () ->
    adminLabClassificationLiveSearch()
  )


@adminLabClassificationLiveSearch = adminLabClassificationLiveSearch = () ->
  $("#admin-lab-classification-search-box").addClass("loading")
  form = $("#admin-lab-classification-live-search")
  lab_id = form.attr('data-laboratory-id')
  url = "/laboratory/#{lab_id}/admin_lab_classification_live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#admin-lab-classification-search-box").removeClass("loading")
    $("#admin-lab-classifications-list").empty().html(html)
    $("#admin-lab-classifications-list .admin-lab-classification-item:first").click()
  )

$(document).on('click', '.admin-lab-classification-item', () ->
    $('.admin-lab-classification-item').removeClass('selected')
    $(this).addClass('selected')
    url = '/laboratory_service_classifications/' + $(this).attr('data-classification-id') + '/edit'


    $.get(url, {}, (html) ->
      $('#admin-classification-details').html(html)
    )
  )

$(document).on('ajax:beforeSend', '#edit-classification-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-classification-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    id = res['id']
    $('#classification_name_' + id).html(res['name'])
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#edit-classification-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('click', '#add-new-classification-button', () ->
    url = '/laboratory/' + $(this).attr('data-laboratory-id') + '/new_classification'
    $.get(url, {}, (html) ->
      $('#admin-classification-details').empty().html(html)
    )
  )

$(document).on('ajax:beforeSend', '#new-lab-service-classification-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-lab-service-classification-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#admin-lab-classification-search-box').val(res['name'])
    adminLabClassificationLiveSearch()
  )

$(document).on('ajax:error', '#new-lab-service-classification-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#----------------------------
# LAB ADMIN IMAGES
#----------------------------
$(document).on('ajax:beforeSend', '.admin-images', (evt, xhr, settings) ->
    lab_id = $(this).attr('data-laboratory-id')
    url = '/laboratory/' + lab_id + '/admin_images'
  )
$(document).on('ajax:success', '.admin-images', (evt, data, status, xhr) ->
    $('#admin-area').empty().html(data)
  )

$(document).on('ajax:error', '.admin-images', (evt, xhr, status, error) ->
    alert('Error')
  )

$(document).on('ajax:beforeSend', '#new-image-classification-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-image-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
  )

$(document).on('ajax:error', '#new-lab-service-classification-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )


#--------
# OTHER
#--------



$(document).on('click', '.show_fields', () ->
  the_id = $(this).attr('id')
  fields = $('#' + the_id.replace('show_',''))
  fields.slideDown()
  $(this).hide()
)
