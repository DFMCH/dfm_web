module DfmWebHelper

  def dfm_web_asset_tags
    nonce = content_security_policy_nonce
    safe_join([
      stylesheet_link_tag("dfm_web/dfm_web", nonce: nonce,
        "data-turbo-track" => "reload", "data-dfm-web" => "stylesheet"),
      javascript_include_tag("dfm_web/dfm_web", defer: true, nonce: nonce,
        "data-turbo-track" => "reload", "data-dfm-web" => "script")
    ], "\n")
  end

  # Extract the host application's name and titlecase it.
  # Should `titlecase` incorrectly capitalize your app, add it
  # as an acronym in your inflections.rb
  # > inflect.acronym("HRMed")
  def host_application_title
    if Rails::VERSION::MAJOR >= 6
      Rails.application.class.module_parent_name.to_s.titlecase
    else
      Rails.application.class.parent_name.to_s.titlecase
    end
  end

end
