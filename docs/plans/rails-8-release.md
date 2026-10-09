# DfmWeb 8.0.0 Release Plan

Status: Draft. Implementation is paused pending experiments and approval.

## Release Requirements

- Version the release as **8.0.0** to align with its target Rails version.
- Require Rails 8+ and Ruby 3.2+, the Rails 8.0 minimum. Do not retain Rails 7.2 or earlier support. Initially verify Rails 8.0 and 8.1 on valid Ruby combinations, using a maintained Ruby for development.
- Support Rails 8 applications using either **Propshaft or Sprockets**. Select integration by the configured pipeline, not the Rails major version.
- Remove all `.erb` assets, including dummy application assets. ERB views and layout partials remain supported.
- Ship readable, unminified CSS and JavaScript. Preserve third-party license notices. Disable compression in the demonstration/test application; host applications still control their own deployment compression.
- Modernize runtime behavior, accessibility, development tooling, tests, and documentation without redesigning the framework.
- Drop Internet Explorer support.
- Preserve the existing CSS/JavaScript entrypoints, selectors, and CSS source order wherever practical.
- Preserve ordinary application CSS overrides. Document that replacing individual gem stylesheets by logical path will no longer change a preassembled bundle.
- Include a zero-touch asset inclusion design: adding the gem should supply CSS/JavaScript to ordinary Rails HTML pages without manual activation code, a generator, or consumer build tools. Do not replace application layouts or automatically render DFM navigation/footer/main partials.

## Experiments Before Implementation

The background-image strategy is **not finalized**. The baseline proposal is plain CSS logical asset URLs, native Propshaft rewriting, and a narrowly scoped Sprockets processor.

An alternative is to embed the two PNG backgrounds as base64 data URLs. This would eliminate external background-image resolution and the planned Sprockets URL processor. It has only been discussed, not approved.

Before deciding, compare:

- Original image sizes, encoded sizes, and compressed delivery sizes. Base64 expands the raw payload by approximately one-third before compression.
- Readability of long encoded strings versus separate image assets.
- Independent image caching versus invalidating the stylesheet when an image changes.
- Host CSP requirements: embedded images require `data:` in `img-src`. Do not weaken host CSP automatically.
- Development and production behavior under both pipelines.

Update Phase 2 and its tests after those experiments. Do not start implementation merely because this document has been written.

## Current Findings

- [style.css.erb](../../app/assets/stylesheets/dfm_web/style.css.erb) uses `asset_path` for `terrace-chair.png` and `defective_monitor.png`. Those are the dynamic expressions to replace, rather than freezing deployment URLs or digests at gem build time.
- [dfm_web.css](../../app/assets/stylesheets/dfm_web/dfm_web.css) has 15 Sprockets `require` directives followed by debug rules. Propshaft does not concatenate those directives.
- Propshaft rewrites CSS `url(...)` references to fingerprinted assets. Quoted browser `@import` chains are not a replacement for this bundling behavior. Propshaft generates `public/assets/.manifest.json`; it does not need a hand-written source JSON manifest.
- Sprockets does not rewrite ordinary CSS image URLs by default. Replacing ERB with plain URLs alone would leave a production compatibility gap.
- [engine.rb](../../lib/dfm_web/engine.rb) broadly suppresses exceptions around asset precompilation configuration.
- [dfm_web.js](../../app/assets/javascripts/dfm_web/dfm_web.js) can duplicate hamburger controls and listeners on repeated activation, overwrites `window.onresize`, and adds document Escape listeners per flash message.
- The mobile toggle is a `div`; flash dismissal uses a CSS pseudo-element. Both need genuine accessible controls.
- [dfm_web.gemspec](../../dfm_web.gemspec) still accepts Rails 5.1+, and the dummy application explicitly loads Sprockets.
- Test coverage is primarily helper-oriented. CI configuration targets Ruby 2.3, and packaging/RDoc references a nonexistent `README.rdoc` rather than [README.md](../../README.md).

## Phase 1: Rails 8 Verification Baseline

1. Update the Rails/Ruby requirements and development dependencies to compatible current versions. Let the host application supply its asset pipeline rather than forcing either pipeline as a runtime dependency.
2. Make the existing dummy application select exactly one pipeline using a test/development setting such as `ASSET_PIPELINE=propshaft|sprockets`. Default to Propshaft and use separate processes/dependency configurations for each pipeline.
3. Modernize dummy application defaults and environment configuration in place. Preserve kitchen-sink routes and examples; remove obsolete settings and Turbolinks attributes. Avoid wholesale regeneration or unrelated database/storage scaffolding.
4. Keep isolated helper specs lightweight, and boot the dummy application for integration/system tests. Add a focused regression test for complete CSS delivery and background-image resolution.

**Gate:** Both pipelines boot under Rails 8, existing helper tests pass, and the asset regression test identifies the current incompatibilities before runtime changes begin.

## Phase 2: Plain, Readable Assets

Depends on Phase 1 and the background-image decision.

1. Rename the ERB stylesheet to plain CSS. Under the baseline approach, replace ERB expressions with logical references such as `url("/dfm_web/terrace-chair.png")`, not hardcoded `/assets/...` URLs or release-time digests. Keep existing styling unchanged.
2. Generate a checked-in, readable `dfm_web/dfm_web.css` bundle with a repository-only Ruby task. Keep modular source stylesheets at their existing paths. Do not introduce Sass, Node, browser import chains, or minification.
3. Preserve this explicit source order: `fonts/redhat`, `pure/pure`, `pure/grids-responsive`, `pure/visibility`, `pure/gutter`, `layout`, `flash`, `nav`, `nav_colors`, `style`, `forms`, `tables`, `layout_media`, `dark_mode`, `print`; append the current debug rules last.
4. Make generation deterministic and independent of a Rails application environment. Automatically generate before gem builds; CI checks that committed output matches the sources. Consumer applications do not run a generation step.
5. Replace broad rescue-based engine configuration with pipeline-aware initialization. Propshaft uses its native engine asset paths and URL rewriting. Retain the Sprockets manifest where needed.
6. If separate background assets are retained, register a small Sprockets processor scoped to DFM-owned CSS references. Resolve paths through its asset context and track dependencies. Respect asset hosts/prefixes and host configuration; do not rewrite arbitrary host stylesheets. If embedding is selected instead, omit this processor and test the data URLs/CSP requirements.

**Gate:** Both real pipelines serve the complete CSS in the original order. Verify direct inclusion and Sprockets inclusion inside application CSS, production fingerprints, custom prefixes/hosts, successful image responses, and image-change invalidation. Confirm there are no ERB assets and no minified generated output. With embedding, replace external-image assertions with appropriate data URL and CSP checks.

## Phase 3: Portable JavaScript and Accessibility

May proceed alongside Phase 2 after the verification baseline.

1. Retain `DfmWeb.activate_dfm_web()` as a public API, preserve the namespace, and make initialization repeatable without duplicated controls or listeners.
2. Automatically initialize on DOM readiness, including when the script loads after readiness. Handle optional `turbo:load`, `turbo:frame-load`, and `turbo:before-cache` events without importing or requiring Turbo. Keep all startup logic in external vanilla JavaScript, not inline boot scripts.
3. Use bounded event handling and do not overwrite host resize listeners. Scope navigation queries to DFM markup. Synchronize mobile/desktop behavior at the existing breakpoint and reset transient state before Turbo caches pages.
4. Make pages without DFM navigation or flash markup safe.
5. Replace the hamburger `div` with a real button, accessible name, `aria-controls`, `aria-expanded`, and visible focus. Make dropdowns keyboard reachable, support Escape, and restore relevant focus.
6. Replace flash pseudo-element dismissal with a labelled button while preserving `#notice`/`#alert`, sanitized content, and appropriate alert/status semantics. Avoid whole-message dismissal interfering with links.
7. Remove IE polyfills and their references. Simplify obsolete helper/version-loading paths only when Rails 8 autoload checks establish a safe replacement. Do not blindly upgrade vendored frameworks or perform unrelated cosmetic cleanup.

**Gate:** Browser tests cover plain navigation and actual Turbo fixtures, repeated initialization, host event-handler preservation, keyboard interactions, flash links/dismissal, desktop/mobile transitions, cache restoration, and pages without DFM markup. Use existing Rails/RSpec conventions with automatic browser-driver provisioning; no consumer JavaScript toolchain is required.

## Phase 4: Zero-Touch Asset Inclusion

Depends on Phases 2 and 3. This is the highest-risk addition and needs a separate safety gate.

Proposed design:

1. Register a focused `ActionController::Base` concern through the railtie. Use an after-action hook on rendered, buffered HTML rather than replacing layouts, monkey-patching the view renderer, or buffering arbitrary Rack response bodies.
2. Default `config.dfm_web.auto_include_assets` to true and provide application/controller/action opt-outs. Use Rails asset helpers and CSP nonce helpers, with deferred external JavaScript and Turbo reload tracking. Apply the same behavior to both pipelines.
3. Process only successful full HTML documents with an explicit `head`. Skip HEAD requests, API/JSON, Turbo Streams, redirects/errors, attachments, fragments, streaming/live controllers, and committed responses.
4. Use a structured HTML parser, declaring a direct dependency if needed. Preserve the doctype, document structure, scripts, and forms. Insert DFM CSS before host styles while respecting base/charset ordering, and insert external JavaScript predictably in the head.
5. Leave existing explicit DFM tags in place and avoid duplicates using helper-generated URLs and recognizable DFM metadata. Respect custom asset hosts/prefixes, CSP, and response headers; clear or recompute stale length/representation validators as necessary.
6. Offer one explicit asset-tag helper for opt-out integrations. Do not inject inline startup code or silently relax CSP.

Limits to document:

- Static pages served outside Rails, streaming responses, unusual document layouts, and third-party asset pipelines are outside the automatic guarantee.
- The gem cannot reliably detect DFM code hidden in arbitrary application bundles. Those integrations can disable automatic inclusion. Repeated JavaScript execution should still be safe.
- Automatic asset inclusion does not mean automatically rendering the gem's layout partials.
- If a safety gate exposes an unresolved blocker, revisit the design with the user rather than silently abandoning zero-touch integration.

**Gate:** Request/browser tests cover no-tags/no-activation setup under both pipelines, explicit-tag deduplication, cascade order and computed styles, opt-outs, enforced CSP/nonces, asset hosts/prefixes, base tags, HTML/script/form preservation, response exclusions, caching, and Turbo navigation/reloads.

## Phase 5: CI, Documentation, and Release

1. Replace stale Travis configuration and badge with GitHub Actions. Test Rails 8.0/8.1 with valid Ruby combinations, including minimum compatibility and maintained development Ruby jobs, on both pipelines. Isolate pipeline outputs and caches.
2. Run bundle-freshness, ERB-asset inventory, readability, RSpec, browser, and production-precompilation checks. Do not treat the minimum compatible Ruby as the recommended development version.
3. Correct gem packaging and RDoc to use the existing Markdown README. Include needed generated CSS and implementation files; keep dummy/log/tmp/test outputs out of the runtime package.
4. Set the gem version to `8.0.0`. Document Rails version alignment, breaking requirements, IE removal, automatic activation/inclusion and opt-outs, readable assets, host-controlled compression, partial rendering, and CSS file-shadowing migration concerns. Replace obsolete setup examples with Rails 8 Propshaft and Sprockets guidance while retaining historical release notes.
5. Build and smoke-test the packaged gem in clean Rails 8 applications with each pipeline, in development and after production precompilation. Verify styling, image/font delivery, navigation, flash behavior, mobile/desktop layouts, dark mode, print, and host CSS overrides.

**Gate:** All prior checks pass against the built artifact, not just the source checkout. No commits, tags, publication, or credential-based release automation without separate authorization.

## Implementation Locations

Reuse existing ownership boundaries:

- Dependency, build, and documentation changes: [dfm_web.gemspec](../../dfm_web.gemspec), [Gemfile](../../Gemfile), [Rakefile](../../Rakefile), and [README.md](../../README.md).
- Rails integration: [engine.rb](../../lib/dfm_web/engine.rb), [railtie.rb](../../lib/dfm_web/railtie.rb), [version.rb](../../lib/dfm_web/version.rb), and [lib/dfm_web.rb](../../lib/dfm_web.rb).
- Asset changes: [dfm_web.css](../../app/assets/stylesheets/dfm_web/dfm_web.css), [style.css.erb](../../app/assets/stylesheets/dfm_web/style.css.erb), [dfm_web.js](../../app/assets/javascripts/dfm_web/dfm_web.js), [nav.css](../../app/assets/stylesheets/dfm_web/nav.css), [flash.css](../../app/assets/stylesheets/dfm_web/flash.css), and neighboring responsive styles.
- Sprockets compatibility: [manifest.js](../../app/assets/config/dfm_web/manifest.js).
- Helpers and accessible flash markup: [dfm_web_helper.rb](../../app/helpers/dfm_web_helper.rb) and [_flash.html.erb](../../app/views/layouts/_flash.html.erb).
- Verification setup: [spec_helper.rb](../../spec/spec_helper.rb), [helper specs](../../spec/helpers/dfm_web_helper_spec.rb), and [dummy application configuration](../../spec/dummy/config/application.rb), with neighboring dummy layouts/assets/environment settings.

Proposed new files, only where an existing file is not a suitable home:

- `lib/dfm_web/auto_assets.rb`: isolated automatic inclusion concern.
- `lib/dfm_web/css_bundle.rb`: deterministic bundle generation/checking, exposed through the existing Rakefile rather than a consumer-loaded task.
- `lib/dfm_web/sprockets_css_urls.rb`: conditional on retaining external CSS image references.
- Focused integration/system specs and shared dummy fixtures; avoid numerous standalone test applications.
- `.github/workflows/test.yml`: supported Rails/Ruby/pipeline verification.

## Planned Verification Commands

These describe the future verification setup. The new task and pipeline selection are not implemented yet; each pipeline must use its corresponding Bundler configuration.

```sh
ASSET_PIPELINE=propshaft bundle exec rspec
ASSET_PIPELINE=sprockets bundle exec rspec
bundle exec rake dfm_web:assets:check
bundle exec rake build
```

From the dummy application, separately for each pipeline:

```sh
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
bundle exec rails zeitwerk:check
```

Inspect each pipeline's production manifest and request the generated URLs with production static serving enabled. Run browser checks with and without Turbo, desktop/mobile viewports, computed-style and asset-loading assertions, dark mode, and print emulation.

## Status and Next Decision

This document records the plan only. Implementation and release verification have not begun. First resolve the background-image experiment, review the automatic inclusion design, and obtain approval to start Phase 1.