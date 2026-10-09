# http://stackoverflow.com/questions/5791211/how-do-i-extract-rails-view-helpers-into-a-gem

require File.dirname(__FILE__) + "/../../app/helpers/dfm_web_helper"
require_relative "auto_assets"

module DfmWeb
  class Railtie < Rails::Railtie
    config.dfm_web = ActiveSupport::OrderedOptions.new
    config.dfm_web.auto_include_assets = true

    initializer "dfm_web_helper" do
      ActiveSupport.on_load( :action_view ){ include DfmWebHelper }
    end

    initializer "dfm_web.auto_assets" do
      ActiveSupport.on_load(:action_controller_base) do
        include DfmWeb::AutoAssets
      end
    end
  end
end
