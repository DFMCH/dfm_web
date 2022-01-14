// DFM Web Javascript
// Originally written in coffeescript, converted to JS with http://js2.coffee/

// DfmWeb Namespace
// https://robots.thoughtbot.com/module-pattern-in-javascript-and-coffeescript
window.DfmWeb = {};

// Add this method within your initialization block:
// Vanilla:
// $(document).on 'ready page:load', ->
//   DfmWeb.activate_dfm_web();

// Turbolinks:
// $(document).on 'turbolinks:load', ->
//   DfmWeb.activate_dfm_web();

DfmWeb.activate_dfm_web = function() {

  // Hide the #notice and #alert messages by clicking the [X] or pressing escape key
  document.querySelectorAll('#notice, #alert').forEach(node => {
    node.addEventListener('click', (event) => {
      console.log(node);
      node.style.display = 'none';
    });

    // If either ID exists, close by pressing Escape
    document.addEventListener('keyup', (key) => {
      if (key.code == 'Escape') {
        node.style.display = 'none';
      }
    });
  });

    // NAV BAR
    //
    // Insert the Hamburger if there are menu 2+ items
    // Add "has_hamburger" class to the ul so CSS can know which way to show it.
    if ($('#nav ul.right li').length > 1) {
        $('ul.right').after('<div id="hamburger"></div>');
        $('ul.right').addClass('has_hamburger');
    }

    // Show the Mobile Menu on Hamburger Click
    $('nav #hamburger').click(function() {
        return $("nav #nav ul.has_hamburger").toggle();
    });

    // If you've toggled the Mobile menu it breaks larger sizes.  Reset on resize.
    window.onresize = function() {
        if (window.innerWidth > 1023) {
            return $("nav #nav ul.has_hamburger").css('display', 'inline-block');
        } else {
            return $("nav #nav ul.has_hamburger").css('display', 'none');
        }
    };

    // iPads don't have :hover, so hide the menu if the user clicks anything in <main>
    $('main').click(function() {
        if (window.innerWidth <= 1023) {
            return $("nav #nav ul.has_hamburger").css('display', 'none');
        }
    });
    // Deal with Really long menus
    return $("#nav > ul > li > ul").each(function() {
        if ($(this).children('li').length > 10) {
            return $(this).addClass('crowded');
        }
    });
};
