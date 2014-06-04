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