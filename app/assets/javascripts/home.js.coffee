# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#-----------
# NAVIGATION
#-----------
$('#nav-home')
  .live('click', () ->
    url = '/home'
    setHash('#!/home', true)
    $('.nav-item').removeClass('selected')
    $('#nav-home').addClass('selected')
  )

$('#nav-new-request')
  .live('click', () ->
    url = '/new-request'
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-new-request').addClass('selected')
  )

$('#nav-my-requests')
  .live('click', () ->
    url = '/my-requests'
    setHash('#!' + url, true)
    $('.nav-item').removeClass('selected')
    $('#nav-my-requests').addClass('selected')
  )



#--------------
# LOCATION HASH
#-------------- 
setHash = (h, get_url) ->
  hash = h
  window.location.hash = hash
  checkHash() if get_url

checkHash = () ->
  if window.location.hash != hash
    hash = window.location.hash
    if (hash.slice(0, 2) == '#!' && hash.length > 3) 
      url = hash.slice(2 - hash.length) + '?__from__=url'
      $.get(url, {}, (html) ->
        $('#workarea').html(html)
      )
