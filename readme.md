# Vfs - Virtual File System

Handy and simple abstraction over any storage that can represent concept of File and Directory (or at least part of it).
The Vfs for File System is kinda the same as ActiveRecord is for Relational Databases.

Currently, there are following implementations available:

- local file system
- remote file system (over ssh)

## Goals

- **handy, simple and clean** API.
- same API for different storages (Local FS, SSH, Hadoop, or any other , ...).
- should work **simultaneously with different storages**.
- small codebase, easy to extend by others.
- simple storage-driver implementation, easy add new storage types (Hadoop DFS, LDAP, Document Oriented DB, In-Memory, ...).

**Performance**:

- sometimes there's extra call to check if file or dir exist before overriding it
- copy: right now it doesn't use FileUtils.cp_r, it walks on the directory tree and copy each entry individually, so it's probably a little slover.
- right now :move and :rename implemented ASAP by copy & destroy, will be fixed as soon as I'll have time to do it.

## Installation

``` bash
$ gem install vfs
$ gem install vos
```

## Code samples:

``` ruby
gem 'vfs'                                    # Virtual File System
require 'vfs'

gem 'vos'                                    # Virtual Operating System
require 'vos'
```

# Connections, let's deploy our 'cool_app' project from our local box to remote server

``` ruby
server = Box.new('cool_app.com')             # it will use id_rsa, or You can add {user: 'me', password: 'secret'}
me = '~'.to_dir                              # handy shortcut for local FS

deploy_dir = server['apps/cool_app']
projects = me['projects']
```

# Working with dirs, copying dir from any source to any destination (local/remote/custom_storage_type)

``` ruby
projects['cool_app'].copy_to deploy_dir
```

# Working with files

``` ruby
dbc = deploy_dir.file('config/database.yml') # <= the 'config' dir not exist yet
dbc.write("user: root\npassword: secret")    # <= now the 'database.yml' and parent 'config' has been created
dbc.content =~ /database/                    # => false, we forgot to add the database
dbc.append("\ndatabase: mysql")              # let's do it

dbc.update do |content|                      # and add host info
  content + "\nhost: cool_app.com "
end

projects['cool_app/config/database.yml'].    # or just overwrite it with our local dev version
  copy_to! dbc
```

There are also streaming support (read/write/append) with &block, please go to specs for details

# Checks

``` ruby
deploy_dir['config'].exist?                  # => true
deploy_dir.dir('config').exist?              # => true
deploy_dir.file('config').exist?             # => false

deploy_dir['config'].dir?                    # => true
deploy_dir['config'].file?                   # => false
```

# Navigation

``` ruby
config = deploy_dir['config']
config.parent                                # => </apps/cool_app>
config['../..']                              # => </>
config['../..'].dir?                         # => true

deploy_dir.entries                           # => list of dirs and files, also support &block
deploy_dir.files                             # => list of files, also support &block
deploy_dir.dirs                              # => list of dirs, also support &block
```

For more please go to specs (create/update/move/copy/destroy/...)

## Integration with [Vos][vos] (Virtual Operating System)

```ruby
server['apps/cool_app'].bash 'rails production'
```

For more details please go to [Vos][vos] project page.
Or checkout configuration I use to control my production servers [My Cluster][my_cluster] in conjunction with small
configuration tool [Cluster Management][cluster_management].

# Why?

To easy my work: with local FS, remote FS (cluster management, deployment automation), and some specific systems like Hadoop DFS.

Because the API of standard File/Dir/FileUtils classes are just terrible. And there's the reason for it - the goal of thouse tools
is to provide 1-to-1 clone of underlying OS API, instead of provididing handy tool.

And if you want to use remote FS - things are getting even worse and more complicated (Net::SSH & Net::SFTP use a little
different API than local FS, and you has to remember all thouse little quirks).

## License

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.

[vos]: http://github.com/alexeypetrushin/vos
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster