require "rails_helper"

RSpec.describe "DFM interactions", type: :system do
  it "initializes once and preserves host resize handlers" do
    visit "/"
    expect(page).to have_css("button#hamburger", count: 1, visible: :all)
    page.execute_script("window.hostResize = function () {}; window.onresize = window.hostResize; DfmWeb.activate_dfm_web(); DfmWeb.activate_dfm_web();")
    expect(page).to have_css("button#hamburger", count: 1, visible: :all)
    expect(page.evaluate_script("window.onresize === window.hostResize")).to be(true)
  end

  it "supports mobile menu keyboard interaction and desktop resizing" do
    page.current_window.resize_to(800, 900)
    visit "/"
    toggle = find("#hamburger")
    expect(toggle["aria-expanded"]).to eq("false")
    toggle.send_keys(:enter)
    expect(page).to have_css("ul.has_hamburger.is_open")
    expect(toggle["aria-expanded"]).to eq("true")
    toggle.send_keys(:escape)
    expect(page).not_to have_css("ul.has_hamburger.is_open")
    expect(page.evaluate_script("document.activeElement.id")).to eq("hamburger")
    page.current_window.resize_to(1440, 1000)
    expect(page).to have_css("ul.has_hamburger")
  end

  it "dismisses notices with a real keyboard-accessible button" do
    visit "/notice"
    expect(page).to have_css("#notice[role='status']")
    find("#notice [data-dfm-dismiss]").send_keys(:enter)
    expect(page).not_to have_css("#notice")
  end

  it "registers interactions once across duplicate scripts and lifecycle events" do
    page.current_window.resize_to(800, 900)
    visit "/notice"
    page.execute_script(File.read(DfmWeb::Engine.root.join("app/assets/javascripts/dfm_web/dfm_web.js")))
    page.execute_script(<<~JS)
      document.dispatchEvent(new Event("turbo:load"));
      document.dispatchEvent(new Event("turbo:frame-load"));
      DfmWeb.activate_dfm_web();
    JS

    expect(page).to have_css("button#hamburger", count: 1)
    expect(page).to have_css("#notice [data-dfm-dismiss]", count: 1)
    find("#hamburger").click
    expect(page).to have_css("ul.has_hamburger.is_open")
    expect(find("#hamburger")["aria-expanded"]).to eq("true")
  end

  it "clears transient menu and flash state before caching a page" do
    page.current_window.resize_to(800, 900)
    visit "/notice"
    find("#hamburger").click
    expect(page).to have_css("ul.has_hamburger.is_open")
    expect(page).to have_css("#notice")

    page.execute_script('document.dispatchEvent(new Event("turbo:before-cache"));')
    expect(page).not_to have_css("ul.has_hamburger.is_open")
    expect(page).not_to have_css("#notice", visible: :all)
    expect(find("#hamburger")["aria-expanded"]).to eq("false")

    page.execute_script('document.dispatchEvent(new Event("turbo:load"));')
    expect(page).to have_css("button#hamburger", count: 1)
    expect(page).not_to have_css("ul.has_hamburger.is_open")
  end

  it "activates safely without navigation or flash markup" do
    visit "/"
    page.execute_script(<<~JS)
      document.querySelectorAll("nav, #notice, #alert").forEach(function (element) {
        element.remove();
      });
      DfmWeb.activate_dfm_web();
      document.dispatchEvent(new Event("turbo:load"));
      document.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }));
      window.dispatchEvent(new Event("resize"));
    JS

    expect(page).to have_css("main")
    expect(page).not_to have_css("[data-dfm-menu-toggle], [data-dfm-dismiss]", visible: :all)
  end

  it "restores a clean cached page after real Turbo navigation", :real_turbo do
    skip "Run with WITH_TURBO=1" unless Rails.application.config.x.with_turbo

    page.current_window.resize_to(800, 900)
    visit "/notice"
    expect(page.evaluate_script("typeof window.Turbo")).to eq("object")
    expect(page).to have_css("#notice")
    find("#hamburger").click
    expect(page).to have_css("ul.has_hamburger.is_open")
    page.execute_script(<<~JS)
      window.dfmTurboPageToken = "retained";
      document.body.setAttribute("data-dfm-cache-proof", "cached");
      Turbo.visit("/news");
    JS

    expect(page).to have_current_path("/news")
    expect(page).to have_css("button#hamburger", count: 1)
    expect(page).not_to have_css("body[data-dfm-cache-proof]", visible: :all)
    expect(page.evaluate_script("window.dfmTurboPageToken")).to eq("retained")

    page.go_back
    expect(page).to have_current_path("/")
    expect(page).to have_css("body[data-dfm-cache-proof='cached']", visible: :all)
    expect(page).not_to have_css("#notice", visible: :all)
    expect(page).not_to have_css("ul.has_hamburger.is_open")
    expect(page).to have_css("button#hamburger", count: 1)
    expect(find("#hamburger")["aria-expanded"]).to eq("false")
    find("#hamburger").click
    expect(page).to have_css("ul.has_hamburger.is_open")
    expect(find("#hamburger")["aria-expanded"]).to eq("true")
  end

  it "starts without manual tags under enforced CSP and preserves host overrides", :auto_assets do
    page.current_window.resize_to(800, 900)
    visit "/asset_inclusion/secure"

    expect(page).to have_css("button#hamburger", count: 1)
    expect(page).to have_css("head > link[data-dfm-web='stylesheet']", count: 1, visible: :all)
    expect(page).to have_css("head > script[data-dfm-web='script']", count: 1, visible: :all)
    expect(page.evaluate_script("window.dfmHostText")).to eq("<head> & quotes")
    expect(page.evaluate_script('getComputedStyle(document.querySelector(".panel")).backgroundColor'))
      .to eq("rgb(0, 255, 0)")
    expect(page.evaluate_script('document.querySelector("[data-dfm-web=script]").nonce')).not_to be_empty
    expect(find("#hamburger")["aria-expanded"]).to eq("false")
    find("#hamburger").click
    expect(page).to have_css("ul.has_hamburger.is_open")
    find("#notice a").click
    expect(page).to have_current_path("/asset_inclusion/secure", ignore_query: true)
    expect(URI.parse(page.current_url).fragment).to eq("fixture-target")
    expect(page).to have_css("#notice")
    find("#notice [data-dfm-dismiss]").send_keys(:enter)
    expect(page).not_to have_css("#notice")
  end

  it "does not bypass a host CSP that blocks scripts", :auto_assets do
    visit "/asset_inclusion/blocked"

    expect(page).to have_css("head > script[data-dfm-web='script']", count: 1, visible: :all)
    expect(page.evaluate_script("typeof window.DfmWeb")).to eq("undefined")
    expect(page).not_to have_css("[data-dfm-menu-toggle], [data-dfm-dismiss]", visible: :all)
  end
end