# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "comfyway"
set :repo_url, "git@github.com:windyeti/comfyway.git"
set :deploy_to, "/var/www/comfyway"
append :linked_files, "config/database.yml", "config/master.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public", "storage"
set :format, :pretty
set :log_level, :info
set :delayed_job_workers, 2

after 'deploy:publishing', 'unicorn:restart'
