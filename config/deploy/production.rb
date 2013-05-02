# Set the servers for this stage.
role :app, "web1-api.hopto.org"
role :web, "web1-api.hopto.org"

# Set the base path for deployment.
set :deploy_to_base, "/srv/data/devprod-int"

# Set the accessible web domain for this site.
set :base_domain, "api.data.gov"

# Production-ready deployments should exclude git data.
set :copy_exclude, [".git"]

# Set the Rails environment.
set :rails_env, "production"

set :user, "root"
ssh_options[:keys] = ["/vagrant/workspace/aws_nmuerdter.pem"]
