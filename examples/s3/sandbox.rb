require 'vfs'

require 'vos'
require 'vos/drivers/s3'

driver = Vos::Drivers::S3.new \
  access_key_id:     'xxx',
  secret_access_key: 'xxx',
  bucket:            'xxx'

box = Vos::Box.new driver

# Preparing temporary dir for sample and cleaning it before starting.
$sandbox = box['/tmp/vfs_sandbox'].to_dir.destroy