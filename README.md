# DfmWeb


## Install

Gemfile
```ruby
gem 'dfm_web'
```

```bash
bundle install
```

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


application.html.erb
```
  <body>
    <%= render 'layouts/nav' %>
    <%= render 'layouts/flash' %>
    <%= render 'layouts/main' %>
    <%= render 'layouts/footer' %>
  </body>
```

config/initializers/assets.rb
```
Rails.application.config.assets.precompile += %w( dfm_web/* )
```

### Things to remove:
* `scaffold.css`
* `<p id="notice"><%= notice %></p>` Anywhere in your app.




## Kitchen Sink:
![README.png](README.png)

## iPad and Smaller:
![README_IPAD.png](README_IPAD.png)

## Mobile:
![README_MOBILE.png](README_MOBILE.png)
