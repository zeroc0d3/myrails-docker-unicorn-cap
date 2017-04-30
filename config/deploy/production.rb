#server '172.17.0.4', user: 'root', roles: %w{app db web}
server 'ce4e6f5a3526', user: 'root', roles: %w{app db web}

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
