**Documentation:** http://alexeypetrushin.github.com/vfs

Virtual File System provides **clean, simple and unified API over different storages** (Local File System, AWS S3, SFTP, ...).

- very simple and intuitive API.
- same API for different storages.
- work simultaneously with multiple storages.
- small codebase, easy to learn and extend.
- driver implementation is very simple, it is easy to create new drivers.

Such unified API is possible because although the API of storages are different the core concept are almost the same.

Install Vfs with Rubygems:

    gem install vfs

Once installed, You can proceed with the [basic example][basics], there's also [S3 version][s3_basics] and [SFTP version][ssh_basics] (also [S3 backup][s3_backup] and [SSH/SFTP deployment][ssh_deployment] examples availiable).

You can report bugs and discuss features on the [issues page][issues].

## Integration with [Vos][vos] (Virtual Operating System)

Vfs can be used toghether with the Virtual Operating System Tool, and while the Vfs covers all the I/O operations the Vos provides support for remote command execution.
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
[basics]:      http://alexeypetrushin.github.com/vfs/basics.html