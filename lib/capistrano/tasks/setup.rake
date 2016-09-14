require 'capistrano/helpers/nginx_helper'
require 'capistrano/helpers/server_helper'

include NginxHelper
include ServerHelper

namespace :server do

  task :setup => [:defaults, :base, :linked_files, :server_files, :services]

  desc "Prepare the server to receive the config"
  task :base do
    on roles(:app) do
      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/server"
    end
  end

  desc "Install linked files"
  task :linked_files do
    on roles(:app) do
      fetch(:linked_files).each do |filename|
        unless test("[ -f #{shared_path}/#{filename} ]")
          file = begin
            erb_eval("config/deploy/#{filename}.erb")
          rescue
            "config/deploy/#{filename}"
          end
          upload! file, "#{shared_path}/#{filename}"
        end
      end
    end
  end

  desc "Install the server files"
  task :server_files do
    on roles(:app) do
      files = fetch(:nginx_files) + fetch(:server_files, [])
      files.each do |file|
        file_path = upload_to_server(file)
        sudo :ln, "-nfs #{file_path} #{file[:path]}" # symlink
      end
    end
  end

  desc "Install the services"
  task :services do
    on roles(:app) do
      services = fetch(:services)
      services.each do |file|
        file_path = upload_to_server(file)
        sudo :cp, "#{file_path} /usr/lib/systemd/system/#{file[:name]}.service"
        sudo :ln, "-nfs /usr/lib/systemd/system/#{file[:name]}.service /etc/systemd/system/multi-user.target.wants/#{file[:name]}.service"
      end
      # reload systemd
      sudo :systemctl, "daemon-reload"
      # enable services
      services.each do |file|
        sudo :systemctl, :enable, "#{file[:name]}.service"
      end
    end
  end

  task :defaults do
      set :nginx_files, [
          {
              filename: "nginx.conf.erb",
              path: "/etc/nginx/sites-enabled/#{fetch(:application)}"
          }
      ]
      set :services, [
           {
               filename: "puma.service.erb",
               name: "puma_#{fetch(:application)}"
           },
       ]
  end
end
