require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Jpking
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Taipei'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-TW"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # config.web_console.whiny_requests = false

    Capybara::Webkit.configure do |config|
      # Enable debug mode. Prints a log of everything the driver is doing.
      config.debug = true

      # By default, requests to outside domains (anything besides localhost) will
      # result in a warning. Several methods allow you to change this behavior.

      # Silently return an empty 200 response for any requests to unknown URLs.
      # config.block_unknown_urls

      # Allow pages to make requests to any URL without issuing a warning.
      config.allow_unknown_urls

      # Timeout if requests take longer than 5 seconds
      config.timeout = 30

      # Don't raise errors when SSL certificates can't be validated
      config.ignore_ssl_errors

      # Don't load images
      config.skip_image_loading
    end
  end
end
