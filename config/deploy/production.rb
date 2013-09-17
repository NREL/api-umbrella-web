require "dotenv/capistrano"

# Set the servers for this stage.
role :app, "web1.apidatagov.aws", "web2.apidatagov.aws"
role :web, "web1.apidatagov.aws", "web2.apidatagov.aws"

# Set the base path for deployment.
set :deploy_to_base, "/srv"

# Set the accessible web domain for this site.
set :base_domain, "api.data.gov"

# Production-ready deployments should exclude git data.
set :copy_exclude, [".git"]

# Set the Rails environment.
set :rails_env, "production"

set :user, "root"
ssh_options[:keys] = ["/vagrant/workspace/aws_nmuerdter.pem"]
