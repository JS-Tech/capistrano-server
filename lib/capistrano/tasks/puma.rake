namespace :puma do
  %w(start stop restart status).each do |task_name|
    desc "#{task} Puma"
    task task_name do
      on roles(:app), in: :sequence, wait: 5 do
        sudo "#{task_name} puma app=#{current_path}", raise_on_non_zero_exit: false
      end
    end
  end

  before "server:setup", "puma:stop"
  after "server:setup", "puma:start"

  after "deploy:finished", "stop"
  after "deploy:finished", "start"
  after "deploy:finished", "nginx:restart"
end
