# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

if ENV["ASSET_PIPELINE"] == "sprockets"
	Rails.application.config.assets.precompile += %w( dfm_web/* )
	Rails.application.config.assets.precompile << "turbo.js" if Rails.application.config.x.with_turbo
end
