# Example of using SFTP as a storage for [Virtual File System][vfs]

# To use SSH/SFTP we need the SSH driver, You need 'vos', 'net-ssh' and 'net-sftp' gems installed.
#
#     gem install vos net-ssh net-sftp
#
require 'vfs'
require 'vos'
require 'vos/drivers/ssh'

# Initializing SSH driver, if You can connect to server using identity file provide host only.
#
# If the connection requires login and password You need to provide it:
#
#     driver = Vos::Drivers::Ssh.new \
#       host:     'xxx.com',
#       user:     'xxx',
#       password: 'xxx'
#
driver = Vos::Drivers::Ssh.new host: 'xxx.com'

# After creating driver we can create storage.
box = Vos::Box.new driver

# Preparing temporary dir for sample and cleaning it before starting.
$sandbox = box['/tmp/vfs_sandbox'].to_dir.destroy

# [vfs]: index.html