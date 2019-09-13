# DFM Web Common Javascript

# DfmWeb Namespace
# https://robots.thoughtbot.com/module-pattern-in-javascript-and-coffeescript
window.DfmWeb = {};

# Add this method within your initialization block:
# Vanilla:
# $(document).on 'ready page:load', ->
#   DfmWeb.activate_dfm_web();
#
# Turbolinks:
# $(document).on 'turbolinks:load', ->
#   DfmWeb.activate_dfm_web();
#
DfmWeb.activate_dfm_web = ->

  # Hide the #notice and #alert messages by clicking the [X] or pressing escape key
  # stop(true) removes any pending animations.
  # This allows you to have an autohide in your app without breaking the click / ESC action.
  # Example: $('#notice').delay(5000).slideUp('slow')
  $('#notice, #alert').click ->
    $(this).stop(true)
    $(this).slideUp('slow')
  $(document).keyup (e) ->
    if e.keyCode == 27
      $('#notice, #alert').stop(true)
      $('#notice, #alert').slideUp('slow')


  ### NAV BAR ###
  # Insert the Hamburger if there are menu 2+ items
  # Add "has_hamburger" class to the ul so CSS can know which way to show it.
  if $('#nav ul.right li').length > 1
    # console.log("Hamburger! " + $('#nav ul.right > li').length );
    $('ul.right').after('<div id="hamburger"></div>')
    $('ul.right').addClass('has_hamburger')

  # Show the Mobile Menu on Hamburger Click
  $('nav #hamburger').click ->
    $("nav #nav ul.has_hamburger").toggle()

  # If you've toggled the Mobile menu it breaks larger sizes.  Reset on resize.
  window.onresize = ->
    if window.innerWidth > 1023
      $("nav #nav ul.has_hamburger").css('display', 'inline-block')
    else
      $("nav #nav ul.has_hamburger").css('display', 'none')

  # iPads don't have :hover really, so hide the menu if the user clicks anything in <main>
  $('main').click ->
    if window.innerWidth <= 1023
      $("nav #nav ul.has_hamburger").css('display', 'none')

  # Deal with Really long menus
  $("#nav > ul > li > ul").each ->
    if $(this).children('li').length > 10
      $(this).addClass('crowded')
