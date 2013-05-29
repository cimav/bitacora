# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@RequestTypesLiveSearch = RequestTypesLiveSearch = () ->
  form = $("#request-types-live-search")
  url = "/request_types/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#request-types-list").empty().html(html)
    $("#request-types-list .request-type-item:first").click()
  )

$(document).on('keyup', '#request-types-search-box', () ->
    RequestTypesLiveSearch()
  )

$(document).on("click", ".request-type-item", () ->
  id = $(this).attr('data-id')
  url = '/request_types/' + id + '/edit'
  $(".request-type-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#request-types-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-request-types-button", () ->
  url = '/request_types/new'
  $.get(url, {}, (html) ->
    $('#request-types-details').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#new-request-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-request-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#request-types-search-box').val(res['name'])
    RequestTypesLiveSearch()
  )

$(document).on('ajax:error', '#new-request-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-request-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-request-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#request_type_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-request-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )