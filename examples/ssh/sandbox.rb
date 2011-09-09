require 'vfs'

require 'vos'
require 'vos/drivers/ssh'

driver = Vos::Drivers::Ssh.new host: 'xxx.com'

# If Your ssh requires login/password use following:
# driver = Vos::Drivers::Ssh.new host: 'xxx.com', user: 'xxx', password: 'xxx'

box = Vos::Box.new driver

# Preparing temporary dir for sample and cleaning it before starting.
$sandbox = box['/tmp/vfs_sandbox'].to_dir.destroy