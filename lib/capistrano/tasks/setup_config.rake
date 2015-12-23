namespace :deploy do
  desc "Create and update the config files"
  task :setup_config do
    on roles(:app) do

      application = fetch(:application)
      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/server"

      fetch(:linked_files).each do |filename|
        unless test("[ -f #{shared_path}/#{filename} ]")
          begin
            file = StringIO.new(ERB.new(File.read("config/deploy/#{filename}.erb")).result(binding)) # render .erb files
          rescue
            file = "config/deploy/#{filename}"
          end
          upload! file, "#{shared_path}/#{filename}"
        end
      end

      fetch(:server_files).each do |file|
        raw_filename = file[:name].gsub(/.erb/, '')
        file_path = "#{shared_path}/server/#{raw_filename}"
        eval_file = StringIO.new(ERB.new(File.read("config/deploy/server/#{file[:name]}")).result(binding)) # render .erb files
        upload! eval_file, file_path # upload to the remote server
        sudo :ln, "-nfs #{file_path} #{file[:path]}" # symlinks
      end

      # reload /etc/init
      sudo :initctl, "reload-configuration"
    end
  end
end

namespace :load do
  task :defaults do
    set :server_files, fetch(:server_files, [
      {
        name: "nginx.conf.erb",
        path: "/etc/nginx/sites-enabled/#{fetch(:application)}"
      },
      {
        name: "puma-manager.conf.erb",
        path: "/etc/init/puma-manager.conf"
      },
      {
        name: "puma-upstart.conf.erb",
        path: "/etc/init/puma.conf"
      },
      {
        name: "puma.conf",
        path: "/etc/puma.conf"
      }
    ])
  end
end
