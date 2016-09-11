namespace :nginx do
  %w(start stop restart reload).each do |task_name|
    desc "#{task } Nginx"
    task task_name do
      on roles(:app), in: :sequence, wait: 5 do
        sudo "systemctl #{task_name} nginx.service"
      end
    end
  end

  after "server:setup", "nginx:reload"
end
