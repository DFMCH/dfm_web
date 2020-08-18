module DfmWebHelper

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
