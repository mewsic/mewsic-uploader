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
set :scm,           :git

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }


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

task :staging do
  set :user, 'mewsic'
  set :password, 'plies25}chis'
  set :use_sudo, false

  #set :dbuser, 'mewsic'
  #set :dbpass, 'Leann82-full'
  #set :dbname, 'mewsic_staging'
  #set :dbhost, 'localhost'

  set :deploy_to, "/srv/rails/#{application}"
  set :deploy_via,    :filtered_remote_cache
  set :repository,    'git@github.com:vjt/multitrack-server.git'
  set :repository_cache,    "/var/cache/rails/#{application}"

  role :web, '89.97.211.109'
  role :app, '89.97.211.109'
  role :db, '89.97.211.109', :primary => :true
  role :brb, '89.97.211.109'

  set :rails_env, 'staging'
  set :environment_database, defer { dbname }
  set :environment_dbhost, defer { dbhost }

  namespace :deploy do
    task :restart do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end
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
