require "rails_helper"

RSpec.describe "Automatic DFM asset inclusion", type: :request, auto_assets: true do
  def document
    Nokogiri::HTML5.parse(response.body)
  end

  it "includes readable assets before host styles without layout configuration" do
    get "/asset_inclusion/show"

    expect(response).to have_http_status(:ok)
    expect(document.at_css("head > link[data-dfm-web='stylesheet']")["href"])
      .to eq(ActionController::Base.helpers.asset_path("dfm_web/dfm_web.css"))
    script = document.at_css("head > script[data-dfm-web='script']")
    expect(script["src"]).to eq(ActionController::Base.helpers.asset_path("dfm_web/dfm_web.js"))
    expect(script.key?("defer")).to be(true)
    expect(script["data-turbo-track"]).to eq("reload")
    styles = document.css("head > link[rel~='stylesheet'], head > style")
    expect(styles.first["data-dfm-web"]).to eq("stylesheet")
    expect(styles.last["id"]).to eq("host-overrides")
  end

  it "preserves the doctype, base URL, host script, and form values" do
    get "/asset_inclusion/show"

    parsed_document = document
    expect(parsed_document.internal_subset.name).to eq("html")
    expect(parsed_document.at_css("head > base")["href"]).to eq("/")
    expect(parsed_document.at_css("#host-script").content).to eq('window.dfmHostText = "<head> & quotes";')
    expect(parsed_document.at_css("form")["method"]).to eq("post")
    expect(parsed_document.at_css("input[name='sample']")["value"]).to eq("a & b")
    expect(parsed_document.at_css("#notice a")["href"]).to eq("/asset_inclusion/show#fixture-target")
    head = parsed_document.at_css("head").element_children
    expect(head.index(parsed_document.at_css("base"))).to be < head.index(parsed_document.at_css("link"))
  end

  [false, true].each do |multiple_comments|
    it "includes assets with #{multiple_comments ? 'multiple leading comments including a multiline comment' : 'a leading Rails view annotation'}" do
      get "/asset_inclusion/annotated", params: { multiple_comments: multiple_comments }

      expect(response).to have_http_status(:ok)
      parsed_document = document
      expect(parsed_document.internal_subset.name).to eq("html")
      expect(parsed_document.css("head > link[data-dfm-web='stylesheet']").length).to eq(1)
      expect(parsed_document.css("head > script[data-dfm-web='script']").length).to eq(1)
      expect(response.body).to include("<!-- BEGIN app/views/layouts/application.html.erb -->",
        "<!-- END app/views/layouts/application.html.erb -->")
      if multiple_comments
        expect(response.body).to include("<!-- Additional annotation\non multiple lines -->")
      end
    end
  end

  it "leaves existing explicit asset tags in place without adding duplicates" do
    get "/asset_inclusion/explicit"

    expect(document.css("link[rel~='stylesheet']").length).to eq(1)
    expect(document.css("script[src]").length).to eq(1)
    expect(document.css("[data-dfm-web]")).to be_empty
    expect(response.body).to start_with("<!doctype html>")
  end

  it "deduplicates the explicit asset-tag helper" do
    get "/asset_inclusion/manual"

    expect(document.css("[data-dfm-web='stylesheet']").length).to eq(1)
    expect(document.css("[data-dfm-web='script']").length).to eq(1)
  end

  it "supports application-wide opt-out" do
    allow(Rails.application.config.dfm_web).to receive(:auto_include_assets).and_return(false)

    get "/asset_inclusion/show"

    expect(document.css("[data-dfm-web]")).to be_empty
    expect(response.body).to start_with("<!doctype html>")
  end

  it "supports controller-level opt-out" do
    allow(AssetInclusionController).to receive(:dfm_web_auto_include_assets).and_return(false)

    get "/asset_inclusion/show"

    expect(document.css("[data-dfm-web]")).to be_empty
  end

  it "supports action-level opt-out" do
    get "/asset_inclusion/opt_out"

    expect(document.css("[data-dfm-web]")).to be_empty
  end

  it "does not turn a fragment into a full HTML document" do
    get "/asset_inclusion/fragment"

    expect(response.body).to eq("<section>Fragment only</section>")
  end

  it "does not modify JSON responses" do
    get "/asset_inclusion/json"

    expect(response.media_type).to eq("application/json")
    expect(JSON.parse(response.body)).to eq("message" => "Not an HTML document")
  end

  it "does not modify HTML downloads" do
    get "/asset_inclusion/download"

    expect(response.headers["Content-Disposition"]).to include("attachment")
    expect(document.css("[data-dfm-web]")).to be_empty
    expect(response.body).to start_with("<!doctype html>")
  end

  it "does not buffer or modify a streaming response" do
    get "/asset_inclusion/streaming"

    expect(document.css("[data-dfm-web]")).to be_empty
    expect(response.body).to start_with("<!doctype html>")
  end

  it "does not retain validators for the unmodified document" do
    get "/asset_inclusion/with_validators"

    expect(document.css("[data-dfm-web]").length).to eq(2)
    expect(response.headers["ETag"]).not_to eq('"original-document"')
    expect(response.headers["Last-Modified"]).to be_nil
    expect(response.headers["Content-Length"]).to be_nil.or eq(response.body.bytesize.to_s)
  end

  it "keeps HEAD responses empty" do
    head "/asset_inclusion/show"

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_empty
  end

  it "uses the request nonce without weakening the enforced CSP" do
    get "/asset_inclusion/secure"

    parsed_document = document
    nonce = parsed_document.at_css("script[data-dfm-web='script']")["nonce"]
    expect(nonce).not_to be_empty
    expect(parsed_document.at_css("link[data-dfm-web='stylesheet']")["nonce"]).to eq(nonce)
    expect(parsed_document.at_css("#host-script")["nonce"]).to eq(nonce)
    expect(parsed_document.at_css("#host-overrides")["nonce"]).to eq(nonce)
    policy = response.headers.fetch("Content-Security-Policy")
    expect(policy).to include("default-src 'none'", "script-src 'self' 'nonce-#{nonce}'", "style-src 'self' 'nonce-#{nonce}'")
    expect(policy).not_to include("'unsafe-inline'", "'unsafe-eval'")
    expect(response.headers["Content-Security-Policy-Report-Only"]).to be_nil
  end

  it "preserves a CSP that forbids scripts and styles" do
    get "/asset_inclusion/blocked"

    expect(response.headers.fetch("Content-Security-Policy"))
      .to eq("default-src 'none'; script-src 'none'; style-src 'none'")
  end

  it "uses the controller's configured asset host" do
    original_host = AssetInclusionController.asset_host
    AssetInclusionController.asset_host = "https://cdn.example.test"

    get "/asset_inclusion/show"

    parsed_document = document
    expect(parsed_document.at_css("link[data-dfm-web='stylesheet']")["href"])
      .to start_with("https://cdn.example.test/")
    expect(parsed_document.at_css("script[data-dfm-web='script']")["src"])
      .to start_with("https://cdn.example.test/")
  ensure
    AssetInclusionController.asset_host = original_host
  end

  it "uses the configured asset prefix for both entrypoints" do
    get "/asset_inclusion/show"

    parsed_document = document
    prefix = "#{Rails.application.config.assets.prefix}/"
    expect(URI.parse(parsed_document.at_css("link[data-dfm-web='stylesheet']")["href"]).path)
      .to start_with(prefix)
    expect(URI.parse(parsed_document.at_css("script[data-dfm-web='script']")["src"]).path)
      .to start_with(prefix)
  end
end