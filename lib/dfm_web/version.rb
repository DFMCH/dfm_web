module DfmWeb
  VERSION = "2.0.1"
end


# Version History

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
