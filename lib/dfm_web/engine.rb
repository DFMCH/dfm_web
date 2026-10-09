module DfmWeb
  class Engine < ::Rails::Engine
    initializer "dfm_web.assets" do |app|
      if defined?(Sprockets::Railtie) && app.config.assets.precompile
        app.config.assets.precompile += %w[dfm_web/*]
      end
    end
  end
end
