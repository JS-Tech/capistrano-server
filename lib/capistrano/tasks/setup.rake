require 'capistrano/helpers/nginx_helper'

include NginxHelper

namespace :server do
  desc "Create and update the config files"
  task :setup do
    on roles(:app) do

      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/server"

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

      files = fetch(:nginx_files).concat(fetch(:server_files, []))
      files.concat(fetch(:puma_files)) unless fetch(:side_app, false)
      files.each do |file|
        raw_filename = file[:name].gsub(/.erb/, '')
        file_path = "#{shared_path}/server/#{raw_filename}"
        eval_file = begin
            erb_eval("config/deploy/server/#{file[:name]}")
        rescue
            erb_eval(File.expand_path("../../files/#{file[:name]}", __FILE__))
        end
        upload! eval_file, file_path # upload to the remote server
        sudo :ln, "-nfs #{file_path} #{file[:path]}" # symlinks
      end

      # reload
      sudo :systemctl, "daemon-reload"
    end
  end

  task :defaults do
      set :nginx_files, [
          {
              name: "nginx.conf.erb",
              path: "/etc/nginx/sites-enabled/#{fetch(:application)}"
          }
      ]
      set :puma_files, [
           {
               name: "puma.service.erb",
               path: "/etc/systemd/system/multi-user.target.wants/puma.service"
           },
       ]
  end

  before "server:setup", "server:defaults"

end
