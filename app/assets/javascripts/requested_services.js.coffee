 # CANCELED     = -1
 # INITIAL      = 1
 # RECEIVED     = 2
 # ASSIGNED     = 3
 # SUSPENDED    = 4
 # REINIT       = 5
 # IN_PROGRESS  = 6
 # FINISHED     = 99 

$(document).on('change', '#receive-dialog #requested_service_user_id', () ->
  if $('#requested_service_user_id').val() == '-'
    $('#field_service_start').hide()
    $('#start_service').prop('checked', false)
    $('#requested_service_status').val("2")
  else
    $('#field_service_start').show()
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
