# Config valid only for current version of Capistrano
lock "3.8.1"

set :application, 'app'
set :repo_url,    'git@github.com:zeroc0d3/myrails-docker-unicorn-cap.git'

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml', 'config/secrets.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle'
)

set :keep_releases, 5

set :rbenv_type, :user
set :rbenv_ruby, '2.4.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :bundle_binstubs, -> { shared_path.join('bin') }

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'Compile assets'
  task compile_assets: [:set_rails_env] do
    invoke 'deploy:assets:precompile_local'
    invoke 'deploy:assets:upload_assets'
  end

  namespace :assets do
    desc 'Run the precompile task locally and rsync with shared'
    task :precompile_local do
      run_locally do
       execute 'rm -rf public/assets'
       execute "RAILS_ENV=#{ fetch(:rails_env) } bundle exec rake assets:precompile"
       execute 'tar zcvf assets.tgz public/assets/'
       execute 'mv assets.tgz public/assets/'
      end
    end

    desc 'Upload precompiled assets'
    task :upload_assets do
      on roles(:all) do
       upload!('public/assets/assets.tgz', "#{ release_path }/assets.tgz")
       execute "cd #{ release_path }; tar zxvf assets.tgz; rm assets.tgz"
      end

      run_locally { execute 'rm -rf public/assets' }
    end

    desc 'Fix missing assets'
    task :fix_missing do
      on roles(:all) do
       execute "cd #{ release_path }; cp vendor/assets/images/iCheck/minimal/minimal.png public/assets/iCheck/minimal/minimal.png"
      end
    end
  end
end

##### SIDEKIQ #####
#-------------------------------
# namespace :sidekiq do
#   task :manual_stop do
#     on roles(:web) do
#       execute "kill -9 `cat #{ current_path }/tmp/pids/sidekiq.pid`"
#     end
#   end
#
#   task :manual_start do
#     on roles(:web) do
#       execute "cd #{ release_path }; #{ fetch(:rbenv_prefix) } bundle exec sidekiq --index 0 --pidfile tmp/pids/sidekiq.pid --environment production --logfile log/sidekiq.log --queue default --concurrency 10 --daemon"
#     end
#   end

#   task :manual_restart do
#     on roles(:web) do
#       invoke 'sidekiq:manual_stop'
#       invoke 'sidekiq:manual_start'
#     end
#   end
# end

after 'deploy:publishing', 'deploy:restart'
after 'deploy:restart', 'sidekiq:manual_restart'
after 'deploy:restart', 'deploy:assets:fix_missing'
