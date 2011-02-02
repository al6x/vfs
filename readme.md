# Vfs - Virtual File System

Simple abstraction over anything that has hierarchical structure and concept of 'node' and 'leaf'.

Currently there are following implementations available:

- local file system
- remote file system (over ssh)

# Samples:







    box = Vfs::Box.new host: 'webapp.com', ssh: {user: 'root', password: 'secret'}

    box.upload_directory '/my_project', '/apps/my_project'
    box.bash 'nohup /apps/my_project/server_start'

# Why?

Because API of ruby default stdlib for working with files is just too hard and absolutelly not convinient to use.

  
## TODO

- introduce Entity/Dir/File (the same as in Rush)
- allow to move files between any Boxes, not only between local and remote.
- add support for moving dirs.

[rush]: http://github.com/adamwiggins/rush