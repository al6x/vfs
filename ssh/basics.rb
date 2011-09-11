# Example of [Virtual File System][vfs] working with SFTP.
#
# This is exactly the same [basic example][basics] but this time
# we using SFTP as storage instead of local file system.

# Adding examples folder to load paths.
$LOAD_PATH << File.expand_path("#{__FILE__}/../../..")

# Connecting to SFTP and preparing sandbox. You may take a look at
# the [docs/ssh/sandbox.rb][ssh_sandbox] to see the actual code.
require 'docs/ssh/sandbox'

# Now we just executig [basic example][basics]
# but with the `$storage` set to SFTP.
require 'docs/basics'

# [vfs]:         http://alexeypetrushin.github.com/vfs/basics.html
# [basics]:      http://alexeypetrushin.github.com/vfs/basics.html
# [ssh_sandbox]: http://alexeypetrushin.github.com/vfs/ssh/sandbox.html