# Example of using AWS S3 as a storage for [Virtual File System](index.html)

# To use S3 we need the S3 driver, You need 'vos' and 'aws-sdk' gems installed.
#
#     gem install vos aws-sdk
#
require 'vfs'
require 'vos'
require 'vos/drivers/s3'

# Initializing S3 driver, You need to provide Your AWS credentials.
driver = Vos::Drivers::S3.new \
  access_key_id:     'xxx',
  secret_access_key: 'xxx',
  bucket:            'xxx'

# After creating driver we can create storage.
box = Vos::Box.new driver

# Preparing temporary dir (actually, S3 has no dirs, but it can mimic it)
# for sandbox and cleaning it before starting.
$sandbox = box['/tmp/vfs_sandbox'].to_dir.delete