# DFM Web Common Javascript

# DfmWeb Namespace
# https://robots.thoughtbot.com/module-pattern-in-javascript-and-coffeescript
window.DfmWeb = {};

# Method to filter Table rows by a search query
# Your table must have the class live_table
# Your search field must have the class live_search
# See below for the binding.
filter_table_rows = (searched) ->
  $('.live_table > tbody > tr').show().filter(->
    text = $(this).text()
    ! ~text.indexOf(searched)
  ).hide()


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

  # Activate Tablesorter (add to table)
  $('.tablesorter').tablesorter({widgets: ['zebra']}) unless typeof(tablesorter) == "undefined"

  # Hide the #notice and #alert messages by clicking the [X] or pressing escape key
  $('#notice, #alert').click ->
    $(this).slideUp('slow')
  $(document).keyup (e) ->
    if e.keyCode == 27
      $('#notice, #alert').slideUp('slow')

  # Load anything you want with ajax easily.  Add ajax_load class to a div and set path html5 data attrib.
  $(".ajax_load").each ->
    $(this).load( $(this).data('path') )

  # Activate DatePicker (add to text_field)
  $('.datepicker').datepicker dateFormat: "yy-mm-dd"  unless typeof(datepicker) == "undefined"

  # Live search a table
  filter_table_rows($('#live_search').val())  # Initial Page Load
  $('#live_search').keyup ->                  # Refresh with user input.
    filter_table_rows($(this).val())

  # Submit Form on element change
  $(".auto_submit").change ->
    if this.form.hasAttribute("data-remote")
      $(this).submit()  # Remote form must call submit on a JQuery object
    else
      this.form.submit()  # Regular HTML submit

  # Override an HTML autofocus attribute (nav search bar etc) by adding class: autofocus
  # Javascript is a bad language, so we have to set a zero second delay for this to work.
  setTimeout (-> $('.autofocus').focus()), 0

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
    if $(window).width() > 1023
      $("nav #nav ul.has_hamburger").css('display', 'inline-block')
    else
      $("nav #nav ul.has_hamburger").css('display', 'none')

  # iPads don't have :hover really, so hide the menu if the user clicks anything in <main>
  $('main').click ->
    if $(window).width() <= 1023
      $("nav #nav ul.has_hamburger").css('display', 'none')

  # Deal with Really long menus
  $("#nav > ul > li > ul").each ->
    if $(this).children('li').length > 10
      # console.log("REALLY LONG MENU DETECTED! " + $(this).children('li').length);
      $(this).addClass('crowded')
