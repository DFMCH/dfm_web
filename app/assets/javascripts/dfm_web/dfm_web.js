// DFM Web Javascript

// DfmWeb Namespace
// https://robots.thoughtbot.com/module-pattern-in-javascript-and-coffeescript
window.DfmWeb = {};

// To use the dfm_web.js code, you need to call `DfmWeb.activate_dfm_web();`
// Here are some examples of how you might do that in your application.js

// Rails 6 Javascript
// document.addEventListener("DOMContentLoaded", function() { DfmWeb.activate_dfm_web(); });

// Rails 7 Javascript + Turbo (esbuild in my test)
// document.addEventListener("turbo:load", function() { DfmWeb.activate_dfm_web(); })

// Rails 6 jQuery
// $(document).on('ready page:load', function() { DfmWeb.activate_dfm_web(); });

// Rails 6 jQuery + Turbolinks
// $(document).on('turbolinks:load', function() { DfmWeb.activate_dfm_web(); });


DfmWeb.activate_dfm_web = function() {
  // Hide the #notice and #alert messages by clicking the [X] or pressing escape key
  document.querySelectorAll('#notice, #alert').forEach(function (node) {
    node.addEventListener('click', function () {
      node.style.display = 'none';
    });

    // If either ID exists, close by pressing Escape
    document.addEventListener('keyup', function (key) {
      if (key.code == 'Escape') {
        node.style.display = 'none';
      }
    });
  });

  // NAV BAR
  //
  // Insert the Hamburger if there are menu 2+ items
  // Add "has_hamburger" class to the ul so CSS can know which way to show it.
  if (document.querySelectorAll('#nav ul.right>li').length > 1) {
    var hamburger = document.createElement('div');
    hamburger.setAttribute('id', 'hamburger');
    document.querySelector('#nav ul.right').after(hamburger);
    document.querySelector('ul.right').classList.add('has_hamburger');
  }

  // Show the Mobile Menu on Hamburger Click
  document.querySelectorAll('nav #hamburger').forEach(function (node) {
    node.addEventListener('click', function () {
      document.querySelectorAll('nav #nav ul.has_hamburger').forEach(function (node) {
        node.style.display = node.style.display === 'inline-block' ? 'none' : 'inline-block';
      });
    });
  });


  // If you've toggled the Mobile menu it breaks larger sizes.  Reset on resize.
  window.onresize = function() {
    if (window.innerWidth >= 1024) {
      document.querySelectorAll('nav #nav ul.has_hamburger').forEach(function (node) {
        node.style.display = 'inline-block';
      });
    } else {
      document.querySelectorAll('nav #nav ul.has_hamburger').forEach(function (node) {
        node.style.display = 'none';
      });
    }
  };

  // iPads don't have :hover, so hide the menu if the user clicks anything in <main>
  document.querySelectorAll('main').forEach(function (node) {
    node.addEventListener('click', function () {
      if (window.innerWidth < 1024) {
        document.querySelectorAll('nav #nav ul.has_hamburger').forEach(function (node) {
          node.style.display = 'none';
        });
      }
    });
  });

  // Deal with Really long menus
  // Add "crowded" class to make them more compact.
  document.querySelectorAll('#nav > ul > li > ul').forEach(function (node) {
    if (node.children.length > 10) {
      node.classList.add('crowded');
    }
  });
};
