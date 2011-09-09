$LOAD_PATH << File.expand_path("#{__FILE__}/../../..")

require 'examples/ssh/sandbox'
sandbox = $sandbox

# Preparing sample files.
current_dir = __FILE__.to_entry.parent
sample_app = current_dir['deployment/app']

# Copying app to remote machine.
app = sandbox['apps/app']
sample_app.copy_to app
p app['app.rb'].exist?                          # => true

# Configuring.
config = app['config.yml']
config.write "database: mysql"
config.append "name: app_production"
p app['config.yml'].exist?                       # => true

# Running
p app.bash("echo 'bundle install'")              # => bundle install
p app.bash("echo 'server start'")                # => server start