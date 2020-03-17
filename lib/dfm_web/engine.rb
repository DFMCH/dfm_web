module DfmWeb
  class Engine < ::Rails::Engine
    begin
      Engine.config.assets.precompile += %w( dfm_web/* )
    rescue
      nil
    end
  end
end
