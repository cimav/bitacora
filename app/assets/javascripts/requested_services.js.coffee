 # CANCELED      = -1
 # INITIAL       = 1
 # RECEIVED      = 2
 # ASSIGNED      = 3
 # SUSPENDED     = 4
 # REINIT        = 5
 # IN_PROGRESS   = 6
 # TO_QUOTE      = 21
 # WAITING_START = 22
 # FINISHED      = 99 

$(document).on('change', '#requested_service_user_id', () ->
  if $('#requested_service_user_id').val() == '-'
    $('#service-start').hide()
    $('#start_service').prop('checked', false)
    $('#requested_service_status').val("2")
  else
    $('#service-start').show()
    $('#requested_service_status').val("3")
)

$(document).on('change', '#start_service', () ->
  if $('#start_service').is(':checked')
    $('#requested_service_status').val("6")
  else
    if $('#requested_service_user_id').val() == '-'
      $('#requested_service_status').val("2")
    else 
      $('#requested_service_status').val("3")
)
