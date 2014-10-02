require "dotenv/capistrano"

# Set the servers for this stage.
role :app, "stage-web1.apidatagov.aws", "stage-web2.apidatagov.aws"
role :web, "stage-web1.apidatagov.aws", "stage-web2.apidatagov.aws"
role :migration, "stage-web1.apidatagov.aws"

# Set the base path for deployment.
set :deploy_to_base, "/srv"

# Set the accessible web domain for this site.
set :base_domain, "api-stage.18f.us"
set :base_domain_aliases, ["stage-api.privatedns.org"]

# Production-ready deployments should exclude git data.
set :copy_exclude, [".git"]

# Set the Rails environment.
set :rails_env, "staging"

set :user, "root"
ssh_options[:keys] = ["/vagrant/workspace/aws_nmuerdter.pem"]
