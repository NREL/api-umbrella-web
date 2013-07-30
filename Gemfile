source :rubygems
source "http://torquebox.org/rubygems"

gem "rails", "~> 3.2.6"

# Rails app server
gem "torquebox", "~> 2.3.2", :platforms => [:jruby]

# Abort requests that take too long
gem "rack-timeout"

# MongoDB
gem "mongoid", ">= 3.0.0"

# Structure trees of mongoid documents
gem "mongoid-tree", :require => "mongoid/tree"

# Database seeding
gem "seed-fu"

# Elasticsearch
gem "stretcher"

# OmniAuth-based authentication
gem "devise"
gem "omniauth-cas"

# Form layout and display
gem "simple_form"

# Pagination
gem "kaminari"

# Navigation links
gem "tabs_on_rails"

# Unobtrusive javascript for Rails helpers (things like delete links).
gem "jquery-rails"

gem "crummy"

gem "client_side_validations", ">= 3.2.0"
gem "client_side_validations-simple_form", ">= 2.0.0"

gem "nokogiri"
gem "babosa"

# For running the python pygmentize program
gem "childprocess"

# Views/templates for APIs
gem "rabl"

# Country and state name lookups
gem "countries"

# Custom YAML config files
gem "settingslogic"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'

  # A Sass version of Twitter Bootstrap. This it the basis for our styles and
  # JavaScript components.
  gem "bootstrap-sass"

  # Sass utilities and automatic image spirtes
  gem "compass-rails"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  # For JRuby, use the Node.js execjs runtime - We'll assume it's on the
  # servers so it gets picked up by execjs. It's faster than therubyrhino.

  # JavaScript compression
  gem 'uglifier'

  # Smarter handling of compiled CSS with relative paths (like Jammit)
  gem "sprockets-urlrewriter"

  # Faster asset precompilation and caching.
  #
  # This fork allows cleaning expired assets at the same time as precompiling,
  # so two rake tasks aren't necessary during our cap deploys. This saves
  # significant time under JRuby. Hopefully it'll be merged into the main gem.
  gem "turbo-sprockets-rails3", :git => "https://github.com/GUI/turbo-sprockets-rails3.git"

  # Improve PNG speed for image sprite generation
  gem "oily_png", :platforms => [:ruby]

  # JavaScript Backbone extensions
  gem "marionette-rails"

  # For JavaScript templates
  gem "handlebars_assets"
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "rspec-html-matchers"

  # Real browser testing
  gem "capybara"

  # Headless webkit for capybara
  gem "poltergeist"
end

group :development do
  # Deployment
  gem "capistrano-ext"
  gem "capistrano_nrel_ext", :git => "http://github.com/NREL/capistrano_nrel_ext.git"

  gem "torquebox-server", :platforms => [:jruby]

  gem "yajl-ruby", :require => false, :platforms => [:ruby]
  gem "oj", :require => false, :platforms => [:ruby]

  gem "awesome_print"

  gem "yard", :require => false
  gem "kramdown", :require => false
end
