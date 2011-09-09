# Preparing S3 storage.
$LOAD_PATH << File.expand_path("#{__FILE__}/../../..")
require 'examples/s3/sandbox'
s3 = $sandbox

# Preparing sample files.
current_dir = __FILE__.to_entry.parent
sample_files = current_dir['backup/app']

# Preparing local storage for S3 backup.
local_backup = '/tmp/vfs_sandbox/backup'.to_dir.destroy

# Uploading sample files to S3.
sample_files.copy_to s3['app']
p s3['app/files/bos.png'].exist?             # => true

# Backup files back to local storage.
s3['app'].copy_to local_backup['app']
p local_backup['app/files/bos.png'].exist?   # => true