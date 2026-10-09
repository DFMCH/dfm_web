class AssetInclusionController < ActionController::Base
  skip_after_action :include_dfm_web_assets, only: :opt_out

  def show
    render html: sample_document, layout: false
  end

  def explicit
    tags = view_context.stylesheet_link_tag("dfm_web/dfm_web") +
      view_context.javascript_include_tag("dfm_web/dfm_web")
    render html: sample_document(tags), layout: false
  end

  def manual
    render html: sample_document(view_context.dfm_web_asset_tags), layout: false
  end

  def opt_out
    show
  end

  def fragment
    render html: "<section>Fragment only</section>".html_safe, layout: false
  end

  def json
    render json: { message: "Not an HTML document" }
  end

  def download
    send_data sample_document, filename: "example.html", type: "text/html", disposition: "attachment"
  end

  def streaming
    response.headers["Content-Type"] = "text/html"
    self.response_body = Enumerator.new { |output| output << sample_document }
  end

  def with_validators
    response.headers["ETag"] = '"original-document"'
    response.headers["Last-Modified"] = "Thu, 01 Oct 2026 00:00:00 GMT"
    show
  end

  def secure
    request.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(18) }
    request.content_security_policy_nonce_directives = %w[script-src style-src]
    request.content_security_policy = ActionDispatch::ContentSecurityPolicy.new do |policy|
      policy.default_src :none
      policy.script_src :self
      policy.style_src :self
      policy.font_src :self, :data
      policy.img_src :self, :data
      policy.base_uri :self
      policy.form_action :self
    end
    show
  end

  def blocked
    request.content_security_policy = ActionDispatch::ContentSecurityPolicy.new do |policy|
      policy.default_src :none
      policy.script_src :none
      policy.style_src :none
    end
    show
  end

  private

  def sample_document(tags = "")
    nonce = view_context.content_security_policy_nonce
    styles = view_context.content_tag(:style, ".panel { background-color: lime; }".html_safe,
      id: "host-overrides", nonce: nonce)
    script = view_context.content_tag(:script, 'window.dfmHostText = "<head> & quotes";'.html_safe,
      id: "host-script", nonce: nonce)
    flash_link = view_context.link_to("A usable flash link", "#{request.path}#fixture-target")
    <<~HTML.html_safe
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>DFM asset inclusion fixture</title>
          <base href="/">
          #{tags}
          #{styles}
          #{script}
        </head>
        <body>
          <nav><div id="nav"><ul class="right"><li><a href="/">Home</a></li><li><a href="/news">News</a></li></ul></div></nav>
          <div id="notice" role="status"><div>#{flash_link}</div></div>
          <form action="/form_submit" method="post"><input name="sample" value="a &amp; b"></form>
          <div class="panel" id="fixture-target">Host content</div>
        </body>
      </html>
    HTML
  end
end