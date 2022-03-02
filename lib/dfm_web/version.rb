module DfmWeb
  VERSION = "5.0.1"
end


# Version History

# 5.0.1   Restore compatibility with Internet Explorer 11.
# 5.0.0   Remove jQuery as a requirement and update README etc for Rails 7.
# 4.1.3   Accessibility and Print media improvements. Added /print demo to Dummy app.
# 4.1.2   Add example theme-colors to dummy & Update NAV CSS. Added a nav search box.
# 4.1.1   Remove alpha channel on option/select background as it's unsupported in Windows.
# 4.1.0   Add dark-mode (automatic based on system dark/light mode)
# 4.0.7   Fix deprecation with Rails 6+. Removed insecure excel_icon helper.
# 4.0.6   Updated Mailer template.
# 4.0.5   Improved Print CSS.
# 4.0.4   Improved font appearance in tables when verlog.css isn't available.
# 4.0.3   Removed incorrect html background-color from <= Large sizes.
# 4.0.2   Optimize png files and add spacing to word/excel.
# 4.0.1   Minor tweak to manifest.js files
# 4.0.0   Adopted UW design language.
# 3.0.0   Removed all Javascript that didn't specifically power the DfmWeb UI.  May require some copy-paste form v2 to your app to upgrade.
# 2.2.4   Check that tablesorter is defined before setting its defaults.
# 2.2.3   Fixed small discrepancy in size definitions between Pure Grids and Visibility.
# 2.2.2   Force right-side NAV dropdown menus to use space to the left.  Prevents menus from causing document level horizontal scroll bars.
# 2.2.1   Fix Chrome table printing bug.  Add "table_hover" class for cells you only want to display on hover.
# 2.2.0   Update CSS comments dealing with footer options.
# 2.1.9   Built in support for always visible footer.
# 2.1.8   Table search feature now case sensitive and rate limited.
# 2.1.7   Shifted the visibility media queries by 1 px (except xlarge). Most important, large starts at 1024px instead of 1025px.
# 2.1.6   Added okay/highlight/warn/alert/gray class rules to panel, lists, headers, buttons, p where missing.
# 2.1.5   Added explicit transparent background on body to aid combining DfmWeb with other CSS frameworks.
# 2.1.4   Fixed menu bug when browser was exactly 1037px wide with a scrollbar.
# 2.1.3   New Table TR modifier classes: okay, highlight, warn, alert, gray.
# 2.1.2   Add submit buttons w/ modifier classes below "button" links with the same classes to the kitchen sink.
# 2.1.1   Eliminate a visual jump when resizing from L to XL.
# 2.1.0   Updated the print version of the "paper" class so it matches the screen version as it should.
# 2.0.9   Added a animation clear on the notice/alert close javascript. This allows you to add new actions in your app.
# 2.0.8   Refreshed Print styles.  Hides Nav, Footer and removes empty space around major elements.
# 2.0.7   Added table to kitchen sink.  Tablesorter is now a added to the dummy app.
# 2.0.6   Robust ajax_load method imported.  Will not render errors / huge responses.
# 2.0.5   Improved the long menu CSS.  No more side-effects!
# 2.0.4   Really long menus will now show with a compact scrollable menu instead of the default.
# 2.0.3   No ugly layout flow in the event your right nav ul overlaps with the left.  They just kinda clobber now.  You have too many menus.
# 2.0.2   Made small and extra small a little smaller.
# 2.0.1   Switched from em to px for visibility classes.  No more 1px deadzones.  Rightmost nav can be a menu now.
# 2.0.0   Near total rewrite of Nav.  Smarter and more foolproof.  NOTE: Removes optional div/a menus and leaves only the ul/li style.
# 1.1.1   Added dfm_web assets to the pipeline so you don't have to.
# 1.1.0   In order to support both Turbolinks and non-Turbolinks sites, DfmWeb must be manually activated now.
# 1.0.7   Copied simple versions of _nav and _footer from the dummy app so they won't be missing assets on new apps.
# 1.0.6   Added "paper" class to simulate printed content.
# 1.0.5   Form element style improvements.  Added optional Mailer Template.
# 1.0.4   Found the mystery 20px and removed it, then removed the two 20px workarounds in the nav.
# 1.0.3   Made the iPad and below background styles !important so you don't have to duplicate them in your host app.
# 1.0.2   Made the background image a transparent png so you can set it's color in CSS.
# 1.0.1   Added "Pure" page to demonstrate the column behavior.
# 1.0.0   Version bump.  We're in production on three apps already.
# 0.0.5   Added .warn and .alert modifier classes for most typography and .panel
# 0.0.4   Added :active class for tables to show a checkmark used in a few apps.
# 0.0.3   Lowered coffee-rails version Requirement
# 0.0.2   Lowered Rails version Requirement
# 0.0.1   Initial Commit
