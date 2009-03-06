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
  :session_domain => 'mewsic.stage.lime5.it',
  :secret      => 'e5ccedb91c7693cf86e16a550f47cb7a83a879fb'
}

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

MP3_OUTPUT_DIR = "/srv/rails/mewsic/shared/audio/"
FLV_INPUT_DIR = "/srv/red5/mewsic/streams/"

MAIN_SERVER = 'http://mewsic.stage.lime5.it/'
AUTH_SERVICE = MAIN_SERVER + 'multitrack/_'
SONG_SERVICE = MAIN_SERVER + 'multitrack/s'

