require "rails_helper"

RSpec.describe "DFM assets", type: :request do
  it "serves the complete readable stylesheet" do
    get ActionController::Base.helpers.asset_path("dfm_web/dfm_web.css")

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/css")
    expect(response.body).to include(".panel {", "clip-path: shape(evenodd", "@font-face", "@media print")
    expect(response.body).not_to include("*= require", "<%")
  end

  it "serves every retained image through Rails asset helpers" do
    %w[apple-touch-icon defective_monitor excel uwcrest word].each do |name|
      get ActionController::Base.helpers.asset_path("dfm_web/#{name}.png")

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("image/png")
    end
  end
end