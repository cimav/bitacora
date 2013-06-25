# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@OtherTypesLiveSearch = OtherTypesLiveSearch = () ->
  form = $("#other-types-live-search")
  url = "/other_types/live_search"
  formData = form.serialize()
  $.get(url, formData, (html) ->
    $("#other-types-list").empty().html(html)
    $("#other-types-list .other-type-item:first").click()
  )

$(document).on('keyup', '#other-types-search-box', () ->
    OtherTypesLiveSearch()
  )

$(document).on("click", ".other-type-item", () ->
  id = $(this).attr('data-id')
  url = '/other_types/' + id + '/edit'
  $(".other-type-item").removeClass("active")
  $(this).addClass('active')
  $.get(url, {}, (html) ->
    $('#other-types-details').empty().html(html)
  )
)

$(document).on("click", "#add-new-admin-other-types-button", () ->
  url = '/other_types/new'
  $.get(url, {}, (html) ->
    $('#other-types-details').empty().html(html)
  )
)

$(document).on('ajax:beforeSend', '#new-other-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#new-other-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#other-types-search-box').val(res['name'])
    OtherTypesLiveSearch()
  )

$(document).on('ajax:error', '#new-other-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )

$(document).on('ajax:beforeSend', '#edit-other-type-form', (evt, xhr, settings) ->
    $('.error-message').remove()
    $('.has-errors').removeClass('has-errors')
  )
$(document).on('ajax:success', '#edit-other-type-form', (evt, data, status, xhr) ->
    $form = $(this)
    res = $.parseJSON(xhr.responseText)
    showFlash(res['flash']['notice'], 'success')
    $('#other_type_display_' + res['id']).html(res['display'])
  )

$(document).on('ajax:error', '#edit-other-type-form', (evt, xhr, status, error) ->
    showFormErrors(xhr, status, error)
  )