require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ApiUmbrella
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/workers)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Choose the compressors to use
    config.assets.js_compressor  = :uglifier

    # Rely on Sass's built-in compressor for CSS minifying.
    # config.assets.css_compressor = :yui

    # Reset the default precompile list list to exclude our vendored submodule
    # stuff. This should go away in Rails 4, where vendor/assets is
    # automatically excluded.
    # Based on the original here:
    # https://github.com/rails/rails/blob/v3.2.17/railties/lib/rails/application/configuration.rb#L48-L49
    config.assets.precompile = [
      proc do |path|
        !File.extname(path).in?(['.js', '.css']) && path !~ /^vendor/
      end,
      /(?:\/|\\|\A)application\.(css|js)$/,
    ]

    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w(
      admin.css
      admin.js
      admin/stats.js
      ckeditor.css
      ie.css
      ie_lt_9.js
    )

    config.ember.variant = :development
    config.handlebars.templates_root = ["admin/templates", "templates"]

    # Use a file-based cache store
    config.cache_store = :file_store, "#{Rails.root}/tmp/cache"

    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = {
      :host => 'api.data.gov',
    }

    config.action_mailer.smtp_settings = {
      :address => 'smtp.mandrillapp.com',
      :port => 465,
      :ssl => true,
      :domain => 'api.data.gov',
      :authentication => 'login',
      :user_name => ENV['MANDRILL_USERNAME'],
      :password => ENV['MANDRILL_PASSWORD'],
    }
  end
end
