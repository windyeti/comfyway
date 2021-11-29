# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "comfyway"
set :repo_url, "git@github.com:windyeti/comfyway.git"
set :deploy_to, "/var/www/comfyway"
append :linked_files, "config/database.yml", "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public", "storage"
set :format, :pretty
set :log_level, :info
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :delayed_job_roles, [:app]
set :delayed_job_pid_dir, '/tmp'
set :unicorn_rack_env, -> { production }

after 'deploy:publishing', 'unicorn:restart'
