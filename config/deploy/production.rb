set :nginx_server_name, "mina-test-736.example.com"
set :rails_env, "production"
set :deploy_to, -> { "/home/#{fetch(:user)}/mina_test_736/production" }
set :hostname, "example.com"
