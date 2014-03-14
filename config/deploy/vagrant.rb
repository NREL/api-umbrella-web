require "capistrano_nrel_ext/recipes/vagrant_deploy"

# Set the servers for this stage.
role :app, "api.vagrant"
role :web, "api.vagrant"
role :migration, "api.vagrant"

# Set the application being deployed.
set :application, "web"

# Set the base path for deployment.
set :deploy_to_base, "/srv/sites"

# Set the accessible web domain for this site.
set :base_domain, "api.vagrant"

# Set the Rails environment.
set :rails_env, "development"

# Set gem bundler options for the development environment.
set :bundle_without, [:test]
set :bundle_flags, "--quiet"

# Don't migrate in development mode.
set :rails_auto_migrate, false

# Set the user the web server runs as.
set :web_server_user, "vagrant"
