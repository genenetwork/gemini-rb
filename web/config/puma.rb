# From: https://qiita.com/Gen_Arch/items/6ea67cc726bd1d865667
require "fileutils"

#root path
app_path = File.expand_path("..", __dir__)
tmp_dirs = ["tmp/pids","tmp/sockets" ,"log"]

tmp_dirs.each do |path|
  mk_path = File.join(app_path, path)
  FileUtils.mkdir_p(mk_path) unless Dir.exist?(mk_path)
end

#default directory
directory app_path
#env mode
environment 'production'

#service daemon - do not for docker version
# daemonize

#process id file
pidfile "#{app_path}/tmp/pids/puma.pid"

#puma status file
state_path "#{app_path}/tmp/pids/puma.state"

#stdout, stderr put file
stdout_redirect "#{app_path}/log/app.log", "#{app_path}/log/app_err.log", true

#thread settting low, high
threads 0, 16

#socket type
bind 'tcp://0.0.0.0:9292' #=> tcp socket
# bind "unix:///#{app_path}/tmp/sockets/puma.sock"

#pumactl
activate_control_app
