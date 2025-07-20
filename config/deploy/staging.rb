set :nginx_server_name, "mina-test-736.staging.railsblueprint.com"
set :rails_env, "staging"
set :deploy_to, -> { "/home/#{fetch(:user)}/mina_test_736/staging" }
set :hostname, "chill"
