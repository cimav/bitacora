# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on("click", "#add-new-maintenance", () ->
  eq_id = $(this).attr('data-eq-id')
  url = '/equipment/' + eq_id + '/maintenances/new'
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#new-maintenance-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-maintenance-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    eq_id = res['equipment_id']
    url = '/equipment/' + eq_id + '/maintenances'
    $.get(url, {}, (html) ->
      $('#maintenance-workarea').empty().html(html)
    )
  )

$(document).on('ajax:error', '#new-maintenance-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-maintenance-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-maintenance-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    eq_id = res['equipment_id']
    url = '/equipment/' + eq_id + '/maintenances'
    $.get(url, {}, (html) ->
      $('#maintenance-workarea').empty().html(html)
    )
  )

$(document).on('ajax:error', '#edit-maintenance-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on("click", ".table-maintenances tr", () ->
  eq_id = $(this).attr('data-eq-id')
  m_id = $(this).attr('data-id')
  url = '/equipment/' + eq_id + '/maintenances/' + m_id
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )
)

$(document).on("click", ".back-maintenance", () ->
  eq_id = $(this).attr('data-eq-id')
  m_id = $(this).attr('data-id')
  url = '/equipment/' + eq_id + '/maintenances/' + m_id
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )
)

@reloadMaintenances = (eq_id) ->
  url = '/equipment/' + eq_id + '/maintenances'
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )

$(document).on("click", ".btn-edit-maintenance", () ->
  eq_id = $(this).attr('data-eq-id')
  m_id = $(this).attr('data-id')
  url = '/equipment/' + eq_id + '/maintenances/' + m_id + '/edit'
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )
)


$(document).on("click", ".back-maintenances", () ->
  eq_id = $(this).attr('data-eq-id')
  url = '/equipment/' + eq_id + '/maintenances/'
  $.get(url, {}, (html) ->
    $('#maintenance-workarea').empty().html(html)
  )
)

$(document).on("change", "#maintenance_status", () ->
  if ($("#maintenance_status" ).val() == "99") 
    $(".man-show").show()
  else
    $(".man-show").hide()
)


