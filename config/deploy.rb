# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "kingof20"
set :repo_url, "git@github.com:iking96/Kingof20Backend.git"

set :user, "deploy"
set :stages, %w(production staging)

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  desc "Restart Rails app"
  task :restart do
    on roles(:app) do
      within current_path do
        execute :touch, File.join('tmp', 'restart.txt')
      end
    end
  end
end

# after "deploy", "deploy:restart"

# Skip deploy:assets:backup_manifest - not using Sprockets
Rake::Task["deploy:assets:backup_manifest"].clear_actions
