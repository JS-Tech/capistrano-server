# Server installations

## User

```
adduser resj

usermod -aG sudo resj
```

## Local and Date

To set the date

```
sudo dpkg-reconfigure tzdata
```

If locales are not set and you got message _perl: warning: Setting locale failed._

```
sudo locale-gen fr_CH.UTF-8 # you can see your local with *locale*
```

## Backup

Use and configure that [upload script](https://github.com/nkcr/Google-Cloud-Storage-Upload). Combine the script with aes encryption. For both provide a key file.

### Install aescrypt for backup encryption

Dowload sources from [AES website](https://www.aescrypt.com/download/) and do

```
make
sudo make install
```

### Restore

Hints : to copy with scp : "$ scp -r -P 44 user@12.34.56.78:folder ~/Desktop"

```
sudo /etc/init.d/unicorn_resj stop

sudo -u postgres psql
# if there is alread a database
> drop database resj_production;
> create database resj_production owner resj;
> \q

sudo -u postgres psql resj_production < backup.txt
sudo /etc/init.d/unicorn_resj restart
```

## Cron jobs (backup and daily rake task)

```
#
# Backup pgsql to google cloud
#
7 20 * * * resj python /home/resj/backup/script/upload_command.py "pg_dump resj_production | aescrypt -e -k /home/resj/backup/storage.key - " gs://backup-reseaujeunesse-ch/pgsql/$(date +\%Y-\%m-\%d-\%H\%M).sql.aes
7  2 * * * resj python /home/resj/backup/script/upload_command.py "pg_dump resj_production | aescrypt -e -k /home/resj/backup/storage.key - " gs://backup-reseaujeunesse-ch/pgsql/$(date +\%Y-\%m-\%d-\%H\%M).sql.aes
7  8 * * * resj python /home/resj/backup/script/upload_command.py "pg_dump resj_production | aescrypt -e -k /home/resj/backup/storage.key - " gs://backup-reseaujeunesse-ch/pgsql/$(date +\%Y-\%m-\%d-\%H\%M).sql.aes
7 14 *  * * resj python /home/resj/backup/script/upload_command.py "pg_dump resj_production | aescrypt -e -k /home/resj/backup/storage.key - " gs://backup-reseaujeunesse-ch/pgsql/$(date +\%Y-\%m-\%d-\%H\%M).sql.aes
#
# Daily rake task
#
7 3     * * *  resj     cd /home/resj/apps/resj/current && bundle exec rake sessions:cleanup RAILS_ENV=production
```

## Swap

Not recommended !

```
dd if=/dev/zero of=/swapfile bs=1024 count=256k
mkswap /swapfile
swapon /swapfile

# /etc/fstab
/swapfile       none    swap    sw      0       0

echo 10 | sudo tee /proc/sys/vm/swappiness
echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
chown root:root /swapfile
chmod 0600 /swapfile
```

## Nginx

### Install

```
apt-get install nginx
```

### Remove default

```
rm /etc/nginx/sites-enabled/default
```

### Firewall

```
ufw allow 'Nginx FULL'
ufw allow 77 # ssh port
ufw enable
```

## Postgresql

### Install

```
apt-get install postgresql libpq-dev
```

### Setup

```
sudo -u postgres psql
> create role resj with createdb login password 'password';
> create database resj_production owner resj;
```

If you need to enable an extension, hstore for example:
```
sudo -u postgres psql dbname
> CREATE EXTENSION hstore;
```

## Git

```
apt-get install git
```

## Node.js

```
apt-get install nodejs
```

## Elasticsearch

Visit the website to get the last instructions [elasticsearch.org/guide/en/elasticsearch/reference/current/setup-repositories.html](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/setup-repositories.html)

### Install

```
wget download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
sudo dpkg -i elasticsearch-1.7.2.deb
sudo update-rc.d elasticsearch defaults
```

### Java

```
apt-get install default-jre
```

### Config

Set the `ES_HEAP_SIZE` with half of the memory available (e.g.: 512m)

Set `http.port` to the desired port

Change system's swapiness value
`sudo vim /etc/sysctl.conf`
`vm.swappiness = 1`

## Imagemagick

```
apt-get install imagemagick
```

## RVM and Ruby

run the commands logged as the deployer user. In case it requires authorization, log off and on.

```
# RVM & Ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
\curl -sSL get.rvm.io | bash -s stable --ruby

# Reload env, lof off and on!
# Bundler
gem install bundler --no-ri --no-rdoc
```

# Capistrano

Install Capistrano, Puma and PG gems to deploy the app

```
# Gemfile
# Use Capistrano for deployment
gem 'capistrano', '~> 3.4.0'

gem 'capistrano-maintenance', require: false

gem 'capistrano-server', git: 'github.com/JS-Tech/capistrano-server'

# rails specific capistrano funcitons
gem 'capistrano-rails'

# integrate bundler with capistrano
gem 'capistrano-bundler'

# if you are using RVM
gem 'capistrano-rvm'
```

Follow instructions from [capistrano](https://github.com/capistrano/capistrano) & [capistrano-server](https://github.com/JS-Tech/capistrano-server)

# Sever permissions

Grant deployer user to write the config files and to execute the init scripts

```
# visudo
deployer ALL=(ALL) NOPASSWD: /etc/init.d/elasticsearch
deployer ALL=(ALL) NOPASSWD: /bin/systemctl * nginx.service
deployer ALL=(ALL) NOPASSWD: /bin/systemctl * puma_nameoftheproject.service
deployer ALL=(ALL) NOPASSWD: /bin/ln -nfs /* /etc/nginx/sites-enabled/*
deployer ALL=(ALL) NOPASSWD: /bin/ln -nfs /* /etc/systemd/system/multi-user.target.wants/*
deployer ALL=(ALL) NOPASSWD: /bin/cp /* /etc/systemd/system/*
deployer ALL=(ALL) NOPASSWD: /bin/systemctl daemon-reload
```

# First deployment

First run `cap stage server:setup` and then edit the files with the secrets

Finally run `cap stage deploy`
