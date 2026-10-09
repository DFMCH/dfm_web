# DfmWeb 8.0.0 Release Plan

Status: Prior local automated verification passed, including both full suites and all four packaged-host scenarios. The subsequent leading Rails view-annotation fix is also verified: the user confirmed automatic-inclusion request specs pass on both pipelines and rebuilt the 8.0.0 gem with the fix. CI matrix/autoload and remaining visual/browser compatibility checks are still pending. Nothing has been published.

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

## Completed Preliminary Work

- Renamed the main stylesheet to [style.css](../../app/assets/stylesheets/dfm_web/style.css). It no longer contains ERB or image asset helper calls.
- Extracted backgrounds into [style_background.css](../../app/assets/stylesheets/dfm_web/style_background.css), loaded immediately before the main style module. The final user-supplied design uses CSS gradients and `clip-path: shape(...)`, not image URLs or SVG data URLs. The user verified the appearance in the browser.
- No special Sprockets CSS URL processor or background-specific `img-src data:` exception is needed. Existing embedded icons/fonts elsewhere still need their existing CSP allowances.
- Removed the unused chair PNG, both background SVG sources, and the lock/molecule PNGs, and cleaned their manifest entries. Kept the Word/Excel icons, crest, Apple touch icon, and `defective_monitor.png`, which remains used by the kitchen-sink image demo.
- Removed the IE-only JavaScript polyfills and their dummy application require. The dummy JavaScript bundle still compiles through Sprockets.
- Background verification now needs to cover CSS shape support/fallback and preserve responsive, dark-mode, and print behavior, including the new pseudo-element. There are no external background images to fingerprint or fetch.

## Implementation Progress

- Rails 8+ and Ruby 3.2+ requirements are in place. The dummy application defaults to Propshaft and supports `ASSET_PIPELINE=sprockets`.
- [css_bundle.rb](../../lib/dfm_web/css_bundle.rb) generates the readable stylesheet from the ordered source modules. Build/check tasks exist, and gem builds invoke stylesheet generation.
- Engine precompilation setup is pipeline-aware; the previous blanket rescue is gone.
- [Asset request specs](../../spec/requests/assets_spec.rb) cover the complete stylesheet and all five retained images. The user confirmed the asset build plus asset/helper specs passed on both pipelines.
- Vanilla JavaScript now includes repeatable activation, automatic DOM/Turbo-event startup, delegated interaction handlers, and real menu/flash buttons. The user confirmed all six current browser examples pass under both pipelines.
- [Browser system specs](../../spec/system/dfm_web_spec.rb) cover repeatable initialization, host resize-handler preservation, keyboard menu interaction, notice dismissal, duplicate script execution, optional lifecycle events, pre-cache cleanup, and missing navigation/flash markup.
- Propshaft previously failed five browser examples because the dummy layout depended on Sprockets directives to include DFM assets. Explicit Propshaft tags fixed that issue, and the user's rerun passed all six.
- The dummy has an opt-in `WITH_TURBO=1` mode that serves the installed, unminified Turbo browser module without making the gem depend on Turbo. The user confirmed the `real_turbo` scenario passes on both pipelines after correcting the Capybara history API to `page.go_back`. This verifies actual visits, restoration from a cached document, menu/flash cleanup, and repeatable interactions.
- [Automatic asset inclusion](../../lib/dfm_web/auto_assets.rb) registers a controller callback, uses the explicit helper, preserves host CSS precedence, deduplicates explicit asset URLs, offers application/controller/action opt-outs, and skips excluded response types. The user confirmed the initial 13 [request specs](../../spec/requests/auto_assets_spec.rb) pass on both pipelines.
- The expanded 19-example `auto_assets` run passed on both pipelines with a non-default prefix. It verifies per-request CSP nonces, enforced restrictive/blocking policies, controller asset hosts, configurable prefixes, zero-tag startup, host CSS overrides, and flash-link usability. The fixture fragment link was corrected to retain its current page despite `<base href="/">`.
- Version 8.0.0 is set. Packaging now includes README.md and excludes dummy/test files, directories, and .DS_Store; RDoc uses the Markdown README. README migration guidance and release notes are updated.
- [GitHub Actions](../../.github/workflows/test.yml) defines Ruby 3.2/3.4, Rails 8.0/8.1, and both-pipeline verification, real Turbo checks, production compilation, and packaged-host checks. The workflow has not run. Local full suites and packaged development/production hosts passed; CI version-matrix/autoload verification remains pending.
- The user confirmed both full suites with `WITH_TURBO=1`, `dfm_web:assets:check`, and `rake build` pass. The resulting local artifact is `pkg/dfm_web-8.0.0.gem`; this is a build, not a published release.
- The user confirmed `dfm_web:release:check` passes all four packaged-host scenarios: Propshaft development/production and Sprockets development/production. [verify_release.rb](../../spec/verify_release.rb) checks package contents, automatic inclusion, host CSS ordering, seven asset responses, production fingerprints, and that the engine was loaded from the extracted package. Runtime dependencies come from the installed bundle; host files and compiled assets are temporary. CI uses the same fixture. Corrections removed a duplicate ERB asset, canonicalized macOS temporary paths, and refreshed Sprockets' boot-time manifest after in-process compilation; these fixture lifecycle fixes do not enable runtime compilation.
- A downstream development app exposed skipped inclusion when Rails prepends view-annotation comments. The guard now accepts single, multiple, and multiline leading comments while retaining full-document requirements. The user confirmed the expanded automatic-inclusion request specs pass on Propshaft and Sprockets and rebuilt `pkg/dfm_web-8.0.0.gem`. Full-suite and packaged-host results above predate this follow-up; they are not claimed as rerun afterward.

## Current Findings

- [style.css](../../app/assets/stylesheets/dfm_web/style.css) and the separate background module are plain CSS with no external background-image references.
- [dfm_web.css](../../app/assets/stylesheets/dfm_web/dfm_web.css) is now a generated plain-CSS bundle of 16 source modules followed by debug rules. Propshaft does not need to concatenate Sprockets directives.
- Propshaft rewrites CSS `url(...)` references to fingerprinted assets. Quoted browser `@import` chains are not a replacement for this bundling behavior. Propshaft generates `public/assets/.manifest.json`; it does not need a hand-written source JSON manifest.
- All retained standalone images are referenced through Rails view helpers or explicitly preserved for downstream applications; no new CSS URL rewriting adapter is needed.
- [engine.rb](../../lib/dfm_web/engine.rb) configures Sprockets precompilation conditionally rather than suppressing initialization errors.
- [dfm_web.js](../../app/assets/javascripts/dfm_web/dfm_web.js) preserves its namespace and registered handlers, automatically activates, and uses button controls. Verify its behavior under repeated startup, Turbo cache restoration, keyboard interactions, and viewport changes.
- [dfm_web.gemspec](../../dfm_web.gemspec) requires Rails 8+ and Ruby 3.2+; the dummy loads its selected asset pipeline.
- Tests now include helper, asset-request, and browser-system coverage. CI modernization and packaging/documentation checks remain release work.

## Phase 1: Rails 8 Verification Baseline

1. Update the Rails/Ruby requirements and development dependencies to compatible current versions. Let the host application supply its asset pipeline rather than forcing either pipeline as a runtime dependency.
2. Make the existing dummy application select exactly one pipeline using a test/development setting such as `ASSET_PIPELINE=propshaft|sprockets`. Default to Propshaft and use separate processes/dependency configurations for each pipeline.
3. Modernize dummy application defaults and environment configuration in place. Preserve kitchen-sink routes and examples; remove obsolete settings and Turbolinks attributes. Avoid wholesale regeneration or unrelated database/storage scaffolding.
4. Keep isolated helper specs lightweight, and boot the dummy application for integration/system tests. Add a focused regression test for complete CSS delivery, background shape rules, and retained view image delivery.

**Gate:** Both pipelines boot under Rails 8, existing helper tests pass, and the asset regression test identifies the current incompatibilities before runtime changes begin.

## Phase 2: Plain, Readable Assets

Depends on Phase 1. Background design and ERB removal are already complete.

1. Preserve the completed plain-CSS background/main stylesheet split. Verify background visibility at the existing responsive breakpoint, dark mode, and print, and graceful behavior in browsers without CSS shape support.
2. Generate a checked-in, readable `dfm_web/dfm_web.css` bundle with a repository-only Ruby task. Keep modular source stylesheets at their existing paths. Do not introduce Sass, Node, browser import chains, or minification.
3. Preserve this explicit source order: `fonts/redhat`, `pure/pure`, `pure/grids-responsive`, `pure/visibility`, `pure/gutter`, `layout`, `flash`, `nav`, `nav_colors`, `style_background`, `style`, `forms`, `tables`, `layout_media`, `dark_mode`, `print`; append the current debug rules last.
4. Make generation deterministic and independent of a Rails application environment. Automatically generate before gem builds; CI checks that committed output matches the sources. Consumer applications do not run a generation step.
5. Replace broad rescue-based engine configuration with pipeline-aware initialization. Propshaft uses its native engine asset paths and URL rewriting. Retain the Sprockets manifest where needed.
6. Keep the retained image assets available through Rails helpers, respecting custom asset hosts/prefixes. Do not add the previously proposed Sprockets background URL processor.

**Gate:** Both real pipelines serve the complete CSS in the original order. Verify direct inclusion and Sprockets inclusion inside application CSS, production fingerprints, custom prefixes/hosts, retained image responses, CSS-only background rendering, and responsive/dark/print overrides. Confirm there are no ERB assets and no minified generated output.

## Phase 3: Portable JavaScript and Accessibility

May proceed alongside Phase 2 after the verification baseline.

1. Retain `DfmWeb.activate_dfm_web()` as a public API, preserve the namespace, and make initialization repeatable without duplicated controls or listeners.
2. Automatically initialize on DOM readiness, including when the script loads after readiness. Handle optional `turbo:load`, `turbo:frame-load`, and `turbo:before-cache` events without importing or requiring Turbo. Keep all startup logic in external vanilla JavaScript, not inline boot scripts.
3. Use bounded event handling and do not overwrite host resize listeners. Scope navigation queries to DFM markup. Synchronize mobile/desktop behavior at the existing breakpoint and reset transient state before Turbo caches pages.
4. Make pages without DFM navigation or flash markup safe.
5. Replace the hamburger `div` with a real button, accessible name, `aria-controls`, `aria-expanded`, and visible focus. Make dropdowns keyboard reachable, support Escape, and restore relevant focus.
6. Replace flash pseudo-element dismissal with a labelled button while preserving `#notice`/`#alert`, sanitized content, and appropriate alert/status semantics. Avoid whole-message dismissal interfering with links.
7. IE polyfill removal is complete. Simplify obsolete helper/version-loading paths only when Rails 8 autoload checks establish a safe replacement. Do not blindly upgrade vendored frameworks or perform unrelated cosmetic cleanup.

**Gate:** Browser tests cover plain navigation and actual Turbo fixtures, repeated initialization, host event-handler preservation, keyboard interactions, flash links/dismissal, desktop/mobile transitions, cache restoration, and pages without DFM markup. Use existing Rails/RSpec conventions with automatic browser-driver provisioning; no consumer JavaScript toolchain is required.

## Phase 4: Zero-Touch Asset Inclusion

Depends on Phases 2 and 3. This is the highest-risk addition and needs a separate safety gate.

Implemented design:

The implementation below passed user-run request/browser and packaged-host checks before the annotation follow-up. It conservatively
handles HTML5 documents with an explicit doctype, `html`, and `head`, allowing whitespace and leading HTML comments before the doctype,
and skips documents with parsing errors. Existing bundled integrations must opt
out because bundled DFM assets cannot reliably be detected.

The leading-comment guard fix and request examples for a single Rails annotation
and multiple/multiline comments passed on both pipelines in the user's laptop runs.
The user rebuilt the gem afterward, so the local artifact includes the fix.

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
- Asset changes: [dfm_web.css](../../app/assets/stylesheets/dfm_web/dfm_web.css), [style.css](../../app/assets/stylesheets/dfm_web/style.css), [style_background.css](../../app/assets/stylesheets/dfm_web/style_background.css), [dfm_web.js](../../app/assets/javascripts/dfm_web/dfm_web.js), [nav.css](../../app/assets/stylesheets/dfm_web/nav.css), [flash.css](../../app/assets/stylesheets/dfm_web/flash.css), and neighboring responsive styles.
- Sprockets compatibility: [manifest.js](../../app/assets/config/dfm_web/manifest.js).
- Helpers and accessible flash markup: [dfm_web_helper.rb](../../app/helpers/dfm_web_helper.rb) and [_flash.html.erb](../../app/views/layouts/_flash.html.erb).
- Verification setup: [spec_helper.rb](../../spec/spec_helper.rb), [helper specs](../../spec/helpers/dfm_web_helper_spec.rb), and [dummy application configuration](../../spec/dummy/config/application.rb), with neighboring dummy layouts/assets/environment settings.

Added files:

- `lib/dfm_web/auto_assets.rb`: isolated automatic inclusion concern.
- `lib/dfm_web/css_bundle.rb`: deterministic bundle generation/checking, exposed through the existing Rakefile rather than a consumer-loaded task.
- Focused integration/system specs and shared dummy fixtures; avoid numerous standalone test applications.
- `.github/workflows/test.yml`: supported Rails/Ruby/pipeline verification.

## Planned Verification Commands

**Execution rule:** Copilot must not run tests in this workspace. Agent-run tests have repeatedly hung. Ask the user to run any required test commands on their laptop and report the results; do not retry through another terminal, test tool, browser runner, or subagent. The commands below are for user execution, not permission for Copilot to run them.

Asset build/check tasks and pipeline selection are implemented. Run each pipeline in a separate process. The focused build and asset/helper checks below have passed according to the user's local run:

```sh
bundle exec rake dfm_web:assets:build
bundle exec rspec spec/requests/assets_spec.rb spec/helpers/dfm_web_helper_spec.rb
ASSET_PIPELINE=sprockets bundle exec rspec spec/requests/assets_spec.rb spec/helpers/dfm_web_helper_spec.rb
```

The six ordinary browser specs passed on both pipelines according to the user's laptop runs. Next, run the new actual-Turbo scenario separately on each pipeline:

```sh
WITH_TURBO=1 ASSET_PIPELINE=propshaft bundle exec rspec spec/system/dfm_web_spec.rb --tag real_turbo
WITH_TURBO=1 ASSET_PIPELINE=sprockets bundle exec rspec spec/system/dfm_web_spec.rb --tag real_turbo
```

The real-Turbo scenario, initial 13 automatic-inclusion request specs, and expanded 19-example coverage below passed on both pipelines according to the user's reruns:

```sh
ASSET_PREFIX=/dfm-test-assets ASSET_PIPELINE=propshaft bundle exec rspec spec/requests/auto_assets_spec.rb spec/system/dfm_web_spec.rb --tag auto_assets
ASSET_PREFIX=/dfm-test-assets ASSET_PIPELINE=sprockets bundle exec rspec spec/requests/auto_assets_spec.rb spec/system/dfm_web_spec.rb --tag auto_assets
```

The full-suite/build commands below have passed according to the user's laptop run:

```sh
bundle install
WITH_TURBO=1 ASSET_PIPELINE=propshaft bundle exec rspec
WITH_TURBO=1 ASSET_PIPELINE=sprockets bundle exec rspec
bundle exec rake dfm_web:assets:check
bundle exec rake build
```

The packaged-gem check below also passed on the user's laptop:

```sh
bundle exec rake dfm_web:release:check
```

This automatically checks Propshaft/Sprockets in development/production, compiles production assets, requests fingerprinted URLs through Rails static serving, and cleans up its isolated fixtures. It leaves the dummy's public asset directory unchanged. CI still needs to execute the full version matrix and autoload check. Remaining visual checks include background support/fallback, dark mode, and print across supported browsers; do not infer these from request-level package checks.

## Status and Next Decision

Implementation and documentation are complete. Prior full-suite and packaged-host gates passed, and the later annotation fix passed focused request specs on both pipelines; the user rebuilt `pkg/dfm_web-8.0.0.gem` with that fix. Verify the downstream development app without its workaround. Before final release approval, run the GitHub Actions version matrix/autoload checks and inspect background support/fallback, dark mode, and print across the application's supported browsers. Publication, commits, and tags require separate authorization. Copilot must not execute tests or the release verification task.