Virtual File System provides **clean, simple and unified API over different storage systems** (Local File System, AWS S3, SFTP, Hadoop DFS, LDAP, Document Oriented DBs, In-Memory, ...).
It is possible to provide such unified API because although those storages have different API the core concept are almost the same.

Currently, there are following implementations available: Local FS, SFTP, S3.

## Goals

- **handy, simple and clean** API.
- same API for different storages (Local FS, SSH, Hadoop, or any other , ...).
- should work **simultaneously with different storages**.
- small codebase, easy to extend and understand.
- driver implementation should be simple, is should be easy to create new drivers.

## Example:

The script below runs on local file system, to see this script running on S3 and SFTP please take a look at the examples folder, there are also samples for S3 backup and deployment over SSH/SFTP.

``` ruby
require 'vfs'

# Preparing temporary dir for sample and cleaning it before starting.
sandbox = '/tmp/vfs_sandbox'.to_dir.destroy

# Let's create simple Hello World project.
project = sandbox['hello_world']            # Our Hello World project.

project['readme.txt'].write 'My shiny App'  # Writing readme file, note that parent dirs
                                            # where created automatically.

# File operations.
readme = project['readme.txt']

# Checking that it's all ok with our readme.
p readme.name                               # => readme.txt
p readme.path                               # => /.../readme.txt
p readme.exist?                             # => true
p readme.file?                              # => true
p readme.dir?                               # => false
p readme.size                               # => 12
p readme.created_at                         # => 2011-09-09 13:20:43 +0400
p readme.updated_at                         # => 2011-09-09 13:20:43 +0400

# Reading.
p readme.read                               # => "My shiny App"
readme.read{|chunk| p chunk}                # => "My shiny App"

# Writing.
readme.append "2 + 2 = 4"
p readme.size                               # => 21

readme.write "My shiny App v2"              # Writing new version of readme.
p readme.read                               # => "My shiny App v2"

readme.write{|s| s.write "My shiny App v3"} # Writing another new version of readme.
p readme.read                               # => "My shiny App v3"

# Copying & Moving.
readme.copy_to project['docs/readme.txt']   # Copying to ./docs folder.
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => true

readme.move_to project['docs/readme.txt']   # Moving to ./docs folder.
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => false


# Dir operations.
project.file('Rakefile').create             # Creating empty Rakefile.

# Checking our project exists and not empty.
p project.exist?                            # => true
p project.empty?                            # => false

# Listing dir content.
p project.entries                           # => [/.../docs, .../Rakefile]
p project.files                             # => [/.../Rakefile]
p project.dirs                              # => [/.../docs]
project.entries do |entry|                  # => ["docs", false]
  p [entry.name, entry.file?]               # => ["Rakefile", true]
end
p project.include?('Rakefile')              # => true

# Copying & Moving, let's create another project by cloning our hello_world.
project.copy_to sandbox['another_project']
p sandbox['another_project'].entries        # => [/.../docs, .../Rakefile]

# Cleaning sandbox.
sandbox.destroy
```

API is the same for all storage types (Local, S3, SFTP, ...). Also API are the same for transfers (copy_to, move_to, ...) between any storage types.
So, for example backup from S3 looks exactly the same as if files are located on the local folder.

## Installation

``` bash
$ gem install vfs

# For S3 and SFTP support install also vos
$ gem install vos
```

## Integration with [Vos][vos] (Virtual Operating System)

Vos can be used toghether with Virtual Operating System Tool, and while the Vfs covers all the I/O operations the Vos provides support for remote command execution.
You can use this combination to fully control remote machines, for example - I'm using it to manage my production servers (setup, administration, deployment, migration, ...).

For more details please go to [Vos][vos] project page.
You can also take look at the actual configuration I'm using to control my servers [My Cluster][my_cluster] (in conjunction with small configuration tool [Cluster Management][cluster_management]).

# Why?

To easy my work: with local FS, remote FS, and some specific systems like Hadoop DFS.

Because the API of standard File/Dir/FileUtils classes are just terrible. And there's the reason for it - the goal of thouse tools is to provide 1-to-1 clone of underlying OS API, instead of provididing handy tool.

And if you want to use remote FS - things are getting even worse and more complicated (Net::SSH & Net::SFTP use a little
different API than local FS, and you has to remember all thouse little quirks).

## License

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.

[vos]: http://github.com/alexeypetrushin/vos
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster