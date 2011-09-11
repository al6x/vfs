# Example of creating AWS S3 Backup with [Virtual File System][vfs].
#
# In this example we uploading sample files to S3 and then
# copying it back to local folder.

# Connecting to S3 and preparing sandbox. You may take a look at
# the [docs/s3/sandbox.rb][s3_sandbox] to see the actual code.
$LOAD_PATH << File.expand_path("#{__FILE__}/../../..")
require 'docs/s3/sandbox'
s3 = $sandbox

# Preparing sample files located in our local folder in
# current directory.
current_dir = __FILE__.to_entry.parent
sample_files = current_dir['backup/app']

# Uploading sample files to S3.
sample_files.copy_to s3['app']
p s3['app/files/bos.png'].exist?             # => true

# Preparing local storage for S3 backup.
local_backup = '/tmp/vfs_sandbox/backup'.to_dir.destroy

# Copying files from S3 to local backup directory.
s3['app'].copy_to local_backup['app']
p local_backup['app/files/bos.png'].exist?   # => true

# [vfs]:     http://alexeypetrushin.github.com/vfs/basics.html
# [s3_sandbox]: http://alexeypetrushin.github.com/vfs/s3/sandbox.html