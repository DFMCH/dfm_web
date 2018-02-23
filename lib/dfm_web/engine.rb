module DfmWeb
  class Engine < ::Rails::Engine
    Engine.config.assets.precompile += %w( dfm_web/* ) rescue nil
  end
end
