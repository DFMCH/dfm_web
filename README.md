# DfmWeb

[![Build Status](https://travis-ci.com/DFMCH/dfm_web.svg?token=196vxcfGdDuHh5NupQpW&branch=master)](https://travis-ci.com/DFMCH/dfm_web)


## Install

Gemfile
```ruby
gem 'dfm_web'
```

Terminal:
```bash
bundle install
```

application.html.erb
```
  <body>
    <%= render 'layouts/nav' %>
    <%= render 'layouts/flash' %>
    <%= render 'layouts/main' %>
    <%= render 'layouts/footer' %>
  </body>
```

# Rails 7 - Vanilla
* `rails new myapp`

application.html.erb
```
<%= stylesheet_link_tag "dfm_web/dfm_web", "data-turbo-track": "reload" %>
```

application.js
```
import "dfm_web"

document.addEventListener("turbo:load", function() {
  DfmWeb.activate_dfm_web();
})
```

importmap.rb
```
pin "dfm_web", to: "dfm_web/dfm_web.js", preload: true
```


# Rails 7 - esbuild + sass
* `rails new myapp --javascript=esbuild --css=sass`
* If not using Turbo, see dfm_web.js for variations on the activation step.

application.html.erb
```
<%= stylesheet_link_tag "dfm_web/dfm_web", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
<%= javascript_include_tag "dfm_web/dfm_web", "data-turbo-track": "reload", defer: true %>
<%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>
```

application.js
```js
document.addEventListener("turbo:load", function() {
  DfmWeb.activate_dfm_web();
})
```

manifest.js
```
//= link dfm_web/manifest.js
```

-------------------------------------------------------------------------------

# Rails 5/6
* Webpacker doesn't support assets from gems.
* We're assuming a traditional sprockets asset-pipeline setup.

application.css
```
 *= require dfm_web/dfm_web
```

application.coffee (Turbolinks)
```
#= require dfm_web/dfm_web

$(document).on 'turbolinks:load', ->
  DfmWeb.activate_dfm_web();
```

application.coffee (Vanilla)
```
#= require dfm_web/dfm_web

$(document).on 'ready page:load', ->
  DfmWeb.activate_dfm_web();
```



config/initializers/assets.rb
```
Rails.application.config.assets.precompile += %w( dfm_web/* )
```

# Changelog:

### Version 5:
* jQuery is no longer a requirement, though it will work just fine if you use it.
* All jQuery based code has been rewritten in Javascript (ES6)
* Updated README and comments on use with Rails 7 (Turbo or plain).
  - Rails 7 tests were performed on an esbuild + sass setup

### Version 4:
* Now using the UW look and feel.
* UW font (verlag) cannot be added to the repo per licensing requirements.
  - To use it in your site add verlag.css to your host app (provided by UW).
  - It will be used if available with fallback to Helvetica etc.
* Navbar img is no longer vertically centered in CSS.
  - Pad your PNG/SVG with transparency.
  - Image be scaled to 42px, but PNG should be at least double that.


### Version 3:
* Javascript to do things other than run the the actual layout has been removed. Specifically:
  - ajax_load
  - auto_submit
  - autofocus
  - datepicker
  - live_search
  - live_table
  - tablesorter
* If you used these features you'll need to pull the javascript from [version 2](https://github.com/DFMCH/dfm_web/blob/518833db5cbbc9aabcfd7ea60dc9960ae67d3406/app/assets/javascripts/dfm_web/dfm_web.js.coffee)

## Kitchen Sink:
* To see the Kitchen Sink, go to spec/dummy and run `rails server`

#### Large Screen:
![README.png](README.png)

#### iPad and Smaller:
![README_IPAD.png](README_IPAD.png)

#### Mobile:
![README_MOBILE.png](README_MOBILE.png)
