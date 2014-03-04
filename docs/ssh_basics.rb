# Example of [Virtual File System](index.html) working with SFTP.
#
# This is exactly the same [basic example](basics.html) but this time
# we using SFTP as storage instead of local file system.

# Adding examples folder to load paths.
$LOAD_PATH << File.expand_path("#{__FILE__}/../..")

# Connecting to SFTP and preparing sandbox. You may take a look at
# the [docs/ssh_sandbox.rb](ssh_sandbox.html) to see the actual code.
require 'docs/ssh_sandbox'

# Now we just executig [basic example](basics.html)
# but with the `$storage` set to SFTP.
require 'docs/basics'