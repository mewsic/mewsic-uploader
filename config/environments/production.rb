# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
config.action_controller.session = {
  :session_key => '_mewsic_sess',
  :session_domain => '.mewsic.com',
  :secret      => 'b0bf476cf838ea5bdb60fcce1209d412c01d631f'
}

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

FLV_INPUT_DIR = "/srv/red5/mewsic/streams/"
MP3_OUTPUT_DIR = "/srv/rails/mewsic/shared/audio/"

MAIN_SERVER = 'http://mewsic.com/'
