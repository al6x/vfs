# Example of Application Deployment using [Virtual File System](index.html).
#
# In this example we uploading sample app files to remote server,
# write database configuration file and restart the server on remote machine.

# Adding examples folder to load paths.
$LOAD_PATH << File.expand_path("#{__FILE__}/../..")

# Connecting to SFTP and preparing sandbox. You may take a look at
# the [docs/ssh_sandbox.rb](ssh_sandbox.html) to see the actual code.
require 'docs/ssh_sandbox'
sandbox = $sandbox

# Preparing sample files located in our local folder in
# current directory.
current_dir = __FILE__.to_entry.parent
sample_app = current_dir['ssh_deployment/app']

# Copying application files to remote machine.
app = sandbox['apps/app']
sample_app.copy_to app
p app['app.rb'].exist?                          # => true

# Writing database configuration file.
config = app['config.yml']
config.write "database: mysql"
config.append "name: app_production"
p app['config.yml'].exist?                       # => true

# Updating gems and restarting the server.
p app.bash("echo 'bundle install'")              # => bundle install
p app.bash("echo 'server start'")                # => server start