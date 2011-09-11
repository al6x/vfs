# Virtual File System provides **clean, simple and unified API over different storages** (Local File System, AWS S3, SFTP, ...).
#
# - very simple and intuitive API.
# - same API for different storages.
# - work simultaneously with multiple storages.
# - small codebase, easy to learn and extend.
# - driver implementation is very simple, it is easy to create new drivers.
#
# Such unified API is possible because although the API of storages are different the core concept are almost the same.
#
# Install Vfs with Rubygems:
#
#     gem install vfs
#
# Once installed, You can proceed with the example below. It uses local file system as storage, there's also [S3 version][s3_basics] and [SFTP version][ssh_basics] (also [S3 backup][s3_backup] and [SSH/SFTP deployment][ssh_deployment] examples availiable).
#
# The project is [hosted on GitHub][project]. You can report bugs and discuss features on the [issues page][issues].

# ### Example

# Preparing sandbox for our sample and cleaning it before starting
# (ignore the `$sandbox` variable, it's needed to reuse this code in S3 and SSH samples).
require 'vfs'
sandbox = $sandbox || '/tmp/vfs_sandbox'.to_dir.destroy

# Creating simple Hello World project.
project = sandbox['hello_world']

# Writing readme file (note that parent dirs where created automatically).
project['readme.txt'].write 'My App'

# We can assign files and dirs to variables, now the `readme` variable refers to our readme.txt file.
readme = project['readme.txt']

# Let's ensure that it's all ok with our readme file and check it's attributes.
p readme.name                               # => readme.txt
p [readme.basename, readme.extension]       # => ['readme', 'txt']
p readme.path                               # => /.../readme.txt
p readme.exist?                             # => true
p readme.file?                              # => true
p readme.dir?                               # => false
p readme.size                               # => 6
p readme.created_at                         # => 2011-09-09 13:20:43 +0400
p readme.updated_at                         # => 2011-09-09 13:20:43 +0400

# Reading - You can read all at once or do it sequentially (input stream
# will be automatically splitted into chunks of reasonable size).
p readme.read                               # => "My shiny App"
readme.read{|chunk| p chunk}                # => "My shiny App"

# The same for writing - write all at once or do it sequentially
# (if there's no file it will be created, if it exists it will be rewriten).
readme.write "My App v2"
readme.write{|stream| stream.write "My App v3"}
p readme.read                               # => "My shiny App v3"

# Appending content to existing file.
readme.append "How to install ..."
p readme.size                               # => 27

# Copying and Moving. It also works exactly the same
# way if You copy or move files and dirs to other storages.
readme.copy_to project['docs/readme.txt']
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => true

readme.move_to project['docs/readme.txt']
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => false

# Let's add empty Rakefile to our project.
project['Rakefile'].write

# Operations with directories - checking our project exists and not empty.
p project.exist?                            # => true
p project.empty?                            # => false

# Listing dir content. There are two versions of methods -
# without block the result will be Array of Entries, with block
# it will iterate over directory sequentially.
p project.entries                           # => [/.../docs, /.../Rakefile]
p project.files                             # => [/.../Rakefile]
p project.dirs                              # => [/.../docs]
project.entries do |entry|                  # => ["docs", false]
  p [entry.name, entry.file?]               # => ["Rakefile", true]
end
p project.include?('Rakefile')              # => true

# You can also use glob (if the storage support it).
p project.entries('**/Rake*')               # => [/.../Rakefile]
p project['**/Rake*']                       # => [/.../Rakefile]

# The result of dir listing is just an array of Entries, so
# You can use it to do interesting things. For example this code will
# calculates the size of sources in our project.
project['**/*.rb'].collect(&:size).reduce(0, :+)

# Copying and moving - let's create another project by cloning our hello_world.
project.copy_to sandbox['another_project']
p sandbox['another_project'].entries        # => [/.../docs, .../Rakefile]

# Cleaning sandbox.
sandbox.destroy

# In this example we covering basics of **Virtual File System**, if You are interesting You can also take
# a look at [S3 backup][s3_backup] and [SSH/SFTP deployment][ssh_deployment] examples.
#
#
# [s3_basics]:      http://alexeypetrushin.github.com/vfs/s3/basics.html
# [ssh_basics]:     http://alexeypetrushin.github.com/vfs/ssh/basics.html
# [s3_backup]:      http://alexeypetrushin.github.com/vfs/s3/backup.html
# [ssh_deployment]: http://alexeypetrushin.github.com/vfs/ssh/deployment.html
#
# [project]:        https://github.com/alexeypetrushin/vfs
# [issues]:         https://github.com/alexeypetrushin/vfs/issues