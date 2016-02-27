namespace :nginx do
  %w(start stop restart reload).each do |task_name|
    desc "#{task } Nginx"
    task task_name do
      on roles(:app), in: :sequence, wait: 5 do
        sudo "#{task_name} nginx"
      end
    end
  end

  after "server:setup", "nginx:reload"
end
