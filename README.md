# Capistrano-server

Capistrano tasks & files to help server deployment with Nginx & Puma.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-server', github: 'JS-Tech/capistrano-server'
```

Then, in your Capfile:

```ruby
require 'capistrano/server'
```
You also need to have a `config/deploy/config` directory with at least a config file for puma named `puma.rb`.
Finally, set the url of your website in your deploy file: `set :url, "example.com"`.

## Usage

The gem uploads the Puma scripts and the Nginx config files to the server. It also uploads and links the files in `config/deploy/config` directory. The files can use ERB templating.

If you need to upload additional files, put them in `config/deploy/server` and use the following options:
```ruby
set :server_files, [{
    name: "elasticsearch.yml.erb",
    path: "/etc/elasticsearch.yml"
}]
```

If you need to deploy multiple apps to the same server, specify the following option in your main application's deploy file:
```ruby
set :applications, ["app1", "app2", "app3"]
```
And in your side applications:
```ruby
set :side_app, true
```

If you want to use SSL, tell the gem to use the correct Nginx config:
```ruby
set :ssl, true
```

If you have subdomains, specify them:
```ruby
set :subdomains, ["sub1", "sub2"]
```

The gem provide a task to run application's tasks on the server: `cap stage tasks:invoke task='permission:add'`

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
