# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_controller.session = {
  :session_key => '_mewsic_sess',
  :secret      => 'e5ccedb91c7693cf86e16a550f47cb7a83a879fb'
}

config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

FLV_INPUT_DIR = "#{RAILS_ROOT}/tmp/spool"
MP3_OUTPUT_DIR = "#{RAILS_ROOT}/tmp/audio"
AUTH_SERVICE = 'http://localhost:3000/multitrack/_'
SONG_SERVICE = 'http://localhost:3000/multitrack/s'
