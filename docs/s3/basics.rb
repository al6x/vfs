# Example of [Virtual File System][vfs] working with AWS S3.
#
# This is exactly the same [basic example][basics] but this time
# we using S3 as storage instead of local file system.

# Adding examples folder to load paths.
$LOAD_PATH << File.expand_path("#{__FILE__}/../../..")

# Connecting to S3 and preparing sandbox. You may take a look at
# the [docs/s3/sandbox.rb][s3_sandbox] to see the actual code.
require 'docs/s3/sandbox'

# Now we just executig [basic example][basics]
# but with the `$storage` set to AWS S3.
require 'docs/basics'

# [vfs]:        ..
# [basics]:     ../basics.html
# [s3_sandbox]: sandbox.html