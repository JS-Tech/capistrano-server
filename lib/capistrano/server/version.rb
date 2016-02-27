module Capistrano
  module Server
    VERSION = "0.5.1"
  end
end

resj ALL=(ALL) NOPASSWD: /bin/ln -* /* /etc/nginx/sites-enabled/*
resj ALL=(ALL) NOPASSWD: /sbin/start puma app=*, /sbin/stop puma app=*, /sbin/restart puma app=*, /sbin/status puma app=*
resj ALL=(ALL) NOPASSWD: /sbin/start nginx, /sbin/stop nginx, /sbin/restart nginx, /sbin/reload nginx
resj ALL=(ALL) NOPASSWD: /bin/ln -* /* /etc/init/puma.conf, /bin/ln -* /* /etc/init/puma-manager.conf, /bin/ln -* /* /home/resj/apps/*, /bin/ln -* /* /etc/puma.conf
resj ALL=(ALL) NOPASSWD: /sbin/initctl reload-configuration
