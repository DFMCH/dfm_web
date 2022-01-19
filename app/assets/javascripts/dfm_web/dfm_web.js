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
        node.addEventListener('click', () => {
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
    if (document.querySelectorAll('#nav ul.right>li').length > 1) {
        hamburger = document.createElement("div")
        hamburger.setAttribute('id', 'hamburger')
        document.querySelector('#nav ul.right').after(hamburger);
        document.querySelector('ul.right').classList.add('has_hamburger');
    }

    // Show the Mobile Menu on Hamburger Click
    document.querySelectorAll('nav #hamburger').forEach(node => {
        node.addEventListener('click', () => {
            document.querySelectorAll("nav #nav ul.has_hamburger").forEach(node => {
                node.style.display = node.style.display === 'inline-block' ? 'none' : 'inline-block';
            });
        });
    });


    // If you've toggled the Mobile menu it breaks larger sizes.  Reset on resize.
    window.onresize = function() {
        if (document.window.innerWidth >= 1024) {
            document.querySelectorAll("nav #nav ul.has_hamburger").forEach(node => {
                node.style.display = 'inline-block';
            });
        } else {
            document.querySelectorAll("nav #nav ul.has_hamburger").forEach(node => {
                node.style.display = 'none';
            });
        }
    };

    // iPads don't have :hover, so hide the menu if the user clicks anything in <main>
    document.querySelectorAll('main').forEach(node => {
        node.addEventListener('click', () => {
            if (document.documentElement.clientWidth < 1024) {
                document.querySelectorAll("nav #nav ul.has_hamburger").forEach(node => {
                    node.style.display = 'none';
                });
            }
        });
    });

    // Deal with Really long menus
    // Add "crowded" class to make them more compact.
    document.querySelectorAll("#nav > ul > li > ul").forEach(node => {
        if (node.children.length > 10) {
            node.classList.add('crowded');
        }
    });
};
