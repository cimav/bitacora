# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@ProvidersLiveSearch = ProvidersLiveSearch = () ->
  form = $("#providers-live-search")
  url = "/providers/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#providers-list").empty().html(html)
    $("#providers-list .provider-item:first").click()
  )

$(document).on('keyup', '#providers-search-box', () ->
    ProvidersLiveSearch()
  )

$(document).on("click", ".provider-item", () ->
  id = $(this).attr('data-id')
  url = '/providers/' + id + '/edit'
  $(".provider-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#providers-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-provider-button", () ->
  url = '/providers/new'
  $.get(url, {}, (html) ->
    $('#providers-details').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#new-provider-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-provider-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#providers-search-box').val(res['name'])
    ProvidersLiveSearch()
  )

$(document).on('ajax:error', '#new-provider-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-provider-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-provider-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#request_type_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-provider-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )
