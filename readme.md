# Rsh - Tiny wrapper over Net::SSH/SFTP

Because they are too hard to use and have terrible API design.

    box = Rsh::Box.new host: 'webapp.com', ssh: {user: 'root', password: 'secret'}

    box.upload_directory '/my_project', '/apps/my_project'
    box.bash 'nohup /apps/my_project/server_start'
  
Honestly my wrapper also not very good. I would like to make API looks like the ['rush'][rush] gem (made by Adam Wiggins)
but it requires a lots of time, maybe I'll do it later.
So, for now it's just a small wrapper to do ssh/io operations not so painfull.

# Ros - Small rake addon for configuration/depoyment management and automation

It may be **usefull if Your claster has about 1-10 boxes**, and tools like Chef, Puppet, Capistrano are too complex and proprietary for your needs.
**It's extremely easy**, there are only 3 methods.

Define your packages, they are just rake tasks, so you probably know how to work with them:

    namespace :os do
      package :ruby do
        applied?{|box| box.has_mark? :ruby}
        apply do |box| 
          box.bash 'apt-get install ruby'
          box.mark :ruby
        end
      end

      package :rails => :ruby do
        applied?{|box| box.has_mark? :rails}
        apply do |box| 
          box.bash 'gem install rails'
          box.mark :rails
        end
      end
    end
    
Define to what it should be applied:

    def each_box &b
      host = ENV['host'] || raise(":host not defined!")
      box = Rsh::Box.new host: host, ssh: {user: 'root', password: 'secret'}
      b.call box
    end
    
Run it:

    $ rake os:rails host=webapp.com
    
**You can use it also for deployment**, exactly the same way, configure it the way you like, it's just rake 
tasks. And by the way, the *box.mark ...* is just an example check, you can use anything there.

It checks if the package already has been applied to box, so you can evolve your configuration and apply 
it multiple times, it will apply only missing packages (or drop the *applied?* clause and it will be applied every run).

## TODO

- introduce Entity/Dir/File (the same as in Rush)
- allow to move files between any Boxes, not only between local and remote.
- add support for moving dirs.


[rush]: http://github.com/adamwiggins/rush