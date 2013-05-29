# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@ServiceTypesLiveSearch = ServiceTypesLiveSearch = () ->
  form = $("#service-types-live-search")
  url = "/service_types/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#service-types-list").empty().html(html)
    $("#service-types-list .service-type-item:first").click()
  )

$(document).on('keyup', '#service-types-search-box', () ->
    ServiceTypesLiveSearch()
  )

$(document).on("click", ".service-type-item", () ->
  id = $(this).attr('data-id')
  url = '/service_types/' + id + '/edit'
  $(".service-type-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#service-types-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-service-types-button", () ->
  url = '/service_types/new'
  $.get(url, {}, (html) ->
    $('#service-types-details').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#new-service-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-service-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#service-types-search-box').val(res['name'])
    ServiceTypesLiveSearch()
  )

$(document).on('ajax:error', '#new-service-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-service-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-service-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#service_type_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-service-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )
