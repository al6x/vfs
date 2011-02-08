# Vfs - Virtual File System

Handy and simple abstraction over any storage that can represent concept of File and Directory (or at least part of it). 
The Vfs for File System Storages is the same as ActiveRecord is for Relational Databases.

Currently, there are following implementations available:

- local file system
- remote file system (over ssh)

## Goals

- **handy, simple and clean** API.
- **high performance** - the same as by using low-level storage API, there should be no extra calls **.
- same API for different storages (Local FS, SSH, Hadoop, or any other , ...).
- should work **simultaneously with different storages**.
- small codebase, easy to extend by others.
- simple storage-driver implementation, easy add new storage types (Hadoop DFS, LDAP, Document Oriented DB, In-Memory, ...).

** all methods should have the same performance as native system calls, except for :move and :rename. Right now they are implemented 
ASAP by using copy+destroy approach, will be fixed as soon as I'll have free time to do it.

## Installation

    $ gem install vfs
    $ gem install vos

## Code samples:
    gem 'vfs'                                    # Virtual File System
    require 'vfs'                              

    gem 'vos'                                    # Virtual Operating System
    require 'vos'


    # Connections, let's deploy our 'cool_app' project from our local box to remote server
    server = Vfs::Box.new(host: 'cool_app.com', ssh: {user: 'me', password: 'secret'})
    me = '~'.to_dir

    cool_app = server['apps/cool_app']
    projects = me['projects']


    # Working with dirs, copying dir from any source to any destination (local/remote/custom_storage_type)
    projects['cool_app'].copy_to cool_app        


    # Working with files
    dbc = cool_app.file('config/database.yml')   # <= the 'config' dir not exist yet
    dbc.write("user: root\npassword: secret")    # <= now the 'database.yml' and parent 'config' has been created
    dbc.content =~ /database/                    # => false, we forgot to add the database
    dbc.append("\ndatabase: mysql")              # let's do it

    dbc.update do |content|                      # and add host info
      content + "\nhost: cool_app.com "
    end                                       

    projects['cool_app/config/database.yml'].    # or just overwrite it with our local dev version
      copy_to! dbc
      
    # there are also streaming support (read/write/append), please go to specs for docs


    # Checks
    cool_app['config'].exist?                    # => true
    cool_app.dir('config').exist?                # => true
    cool_app.file('config').exist?               # => false

    cool_app['config'].dir?                      # => true
    cool_app['config'].file?                     # => false


    # Navigation
    config = cool_app['config']
    config.parent                                # => </apps/cool_app>
    config['../..']                              # => </>
    config['../..'].dir?                         # => true

    cool_app.entries                             # => list of dirs and files, also support &block
    cool_app.files                               # => list of files, also support &block
    cool_app.dirs                                # => list of dirs, also support &block


    # For more please go to specs (create/update/move/copy/destroy/...)
      
## Integration with [Vos][vos] (Virtual Operating System)
    
    server['apps/cool_app'].bash 'rails production'

For more details please go to [Vos][vos] project page. 
Or checkout sample configuration I use to control my production servers [My Cluster][my_cluster] in conjunction with small 
configuration tool [Cluster Management][cluster_management].

# Why?

To easy my work: with local FS, remote FS (cluster management, deployment automation), and some specific systems like Hadoop DFS.

Because the API of standard File/Dir/FileUtils classes are just terrible. And there's the reason for it - the goal of thouse tools
is to provide 1-to-1 clone of underlying OS API, instead of provididing handy tool.

And if you want to use remote FS - things are getting even worse and more complicated (Net::SSH & Net::SFTP use a little
different API than local FS, and you has to remember all thouse little quirks).
  
## TODO

### v 0.1 (all done)

- Vos: Dir.bash
- File.append
- list of entries/files/dirs
- support for efficient copy for Local and SSH storages

### v 0.2 (not started)

- efficient (not copy/destroy) versions of move_to, rename
- glob search for directories: Dir['**/*.yml']
- access via attributes and helpers for unix chmod
- add storages: remote FS over HTTP.

### future

- add storages: Hadoop DFS, MongoDB, Amazon S3

[vos]: http://github.com/alexeypetrushin/vos
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster