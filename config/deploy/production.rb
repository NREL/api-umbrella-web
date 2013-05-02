# Set the servers for this stage.
role :app, "api-web1.anydns.com", "api-web2.anydns.com"
role :web, "api-web1.anydns.com", "api-web2.anydns.com"

# Set the base path for deployment.
set :deploy_to_base, "/srv"

# Set the accessible web domain for this site.
set :base_domain, "api.anydns.com"

# Production-ready deployments should exclude git data.
set :copy_exclude, [".git"]

# Set the Rails environment.
set :rails_env, "production"

set :user, "root"
ssh_options[:keys] = ["/vagrant/workspace/aws_nmuerdter.pem"]
