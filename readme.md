# Vfs - Virtual File System

Simple abstraction over anything that has hierarchical structure and concept of 'node' and 'leaf'.

Currently there are following implementations available:

- local file system
- remote file system (over ssh)

# Goals

- very simple, conciese and clean API over any storage that has FS-like structure.
- same performance as the core Ruby File, Dir, FileUtils for working with local FS.
- the same API for working with different storages (Local FS, SSH, Hadoop, or any other , ...).
- ability to simultaneously work with different storages.
- simple and small codebase, easy to understand and extend.
- easy to add drivers for other FS-like storages (Hadoop DFS, LDAP, Document Oriented DB, In-Memory, ...).

# Samples:

    box = Vfs::Box.new host: 'webapp.com', ssh: {user: 'root', password: 'secret'}

    box.upload_directory '/my_project', '/apps/my_project'
    box.bash 'nohup /apps/my_project/server_start'

# Why?

Because the goal of File/Dir/FileUtils classes is to provide 1-to-1 API clone of underlying OS API, 
not to provide handy tool for FS operations. 

It uses functional design (instead of object-oriented) and bloated naming convetion. 
And after 3 years of Ruby I steel needs sometime to consult RDoc for doing some relativelly basic FS stuff.

And if you want to use remote FS the things getting even worse and more complicated (Net::SSH & Net::SFTP use a little
different API than local FS, and you has to remember all thouse little quirks).
  
## TODO

### v 0.1

- copy_to
- move_to, rename
- Vos: Dir.bash

### v 0.2

- File.append
- Storage.==
- glob search for directories: Dir['**/*.yml']
- list of entries/files/dirs
- access via attributes and helpers for unix chmod
- add driver: remote FS over HTTP.

### future

- add drivers: Hadoop DFS, MongoDB, Amazon S3

[rush]: http://github.com/adamwiggins/rush