# Set the current app's path for later reference. Rails.root isn't available at
# this point, so we have to point up a directory.
app_path = File.expand_path(File.dirname(__FILE__) + '/..')

timeout 300
worker_processes 4
working_directory app_path
pid app_path + '/tmp/unicorn.pid'

stderr_path app_path + '/logs/unicorn.log'
stdout_path app_path + '/logs/unicorn.log'

listen app_path + '/tmp/unicorn.sock', backlog: 64