server '172.31.0.2', user: 'root', roles: %w{app db web}

set :rails_env, 'production'
set :branch,    'master'
set :deploy_to, '/app'
set :tmp_dir,   '/app/tmp'

set :ssh_options, {
  keys: %w(key/id_rsa.pem),
  forward_agent: true
}

set :default_environment, {
  'PATH' => "/ruby_gems/2.4.1/bin:$PATH"
}
