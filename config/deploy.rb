# Please install the Engine Yard Capistrano gem
# gem install eycap --source http://gems.engineyard.com

require 'eycap/recipes'

# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The :deploy_to variable must be the root of the application.

set :keep_releases, 5
set :application,   'multitrack'
set :repository,    'https://svn1.hosted-projects.com/medlar/myousica/myousica/multitrack_server'
set :scm_username,  'ey'
set :scm_password,  'eSkeWeD214'
set :user,          'adelaosrl'
set :password,      'dshUak8s'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :filtered_remote_cache
set :repository_cache,    "/var/cache/engineyard/#{application}"
set :monit_group,   'multitrack'
set :scm,           :subversion
#
set :production_database,'multitrack_production'
set :production_dbhost, 'mysql50-3-master'
#
set :dbuser, 'adelaosrl_db'
set :dbpass, '4asrsWrh'

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

task :production do
  
  role :web, '65.74.174.196:8222' # mongrel, mongrel
  role :app, '65.74.174.196:8222', :mongrel => true, :mongrel => true
  role :db, '65.74.174.196:8222', :primary => true
  role :brb, '65.74.174.196:8221', :no_release => true
  
  #role :app, '65.74.174.196:8222', :no_release => true, :mongrel => true, :mongrel => true
  
  set :rails_env, 'production'
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

# =============================================================================
# Any custom after tasks can go here.

after "deploy:setup", "setup_spool"
desc "create the spool directory"
task :setup_spool, :roles => [:app, :web], :except  => {:no_release => true, :no_symlink => true} do
  run "mkdir -p #{shared_path}/spool"
end

after "deploy:symlink_configs", "symlink_audio"
desc "symlink the audio tank into the public folder"
task :symlink_audio, :roles => [:app, :web], :except => {:no_release => true, :no_symlink => true} do
  run "ln -s #{shared_path}/audio #{latest_release}/public/audio"
end

before "deploy:restart", "restart_bgrb"
desc "restart the backgroundrb server"
task :restart_bgrb, :roles => [:brb] do
  run "cd #{latest_release}; RAILS_ENV=production ruby script/backgroundrb stop || true"
  run "cd #{latest_release}; RAILS_ENV=production nohup ruby script/backgroundrb start >/dev/null 2>&1"
end

# =============================================================================

# Don't change unless you know what you are doing!

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"

# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

