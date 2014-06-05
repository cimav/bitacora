# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@labReqServicesLiveSearch = labReqServicesLiveSearch = () ->
  form = $("#lab-req-serv-live-search")
  url = '/laboratory/' + form.data('laboratory-id')  + '/live_search'
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#lab-req-serv-items").empty().html(html)
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

$(document).on('click', '.lab-req-serv-item', () ->
  sample_id = $(this).data('sample-id')
  id = $(this).data('requested-service-id')
  getLabRequestedService(sample_id, id)
)

getLabRequestedService = (sample_id, id) ->
  url = '/samples/' + sample_id + '/requested_services/' + id + '/lab_view'
  $.get(url, {}, (html) ->
    $('#lab-work-panel').empty().html(html)
    getRequestedService(sample_id, id)
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
    alert('test');
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
    lab_id = $(this).attr('laboratory_id')
    url = '/laboratory/' + lab_id + '/admin_services'
    setHash('#!' + url, false)
  )
$(document).on('ajax:success', '.admin-services', (evt, data, status, xhr) ->
    $('#lab-work-panel').empty().html(data)
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






