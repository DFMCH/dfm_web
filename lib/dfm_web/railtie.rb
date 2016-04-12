# http://stackoverflow.com/questions/5791211/how-do-i-extract-rails-view-helpers-into-a-gem

require File.dirname(__FILE__) + "/../../app/helpers/dfm_web_helper"

module DfmWeb
  class Railtie < Rails::Railtie
    initializer "dfm_web_helper" do
      ActiveSupport.on_load( :action_view ){ include DfmWebHelper }
    end
  end
end
