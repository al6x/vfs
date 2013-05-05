# require 'rake_ext'
#
# project \
#   name: "vfs",
#   gem: true,
#   summary: "Virtual File System - simple and unified API over different storages (Local, S3, SFTP, ...)",
#   # version: '0.4.0',
#
#   author: "Alexey Petrushin",
#   homepage: "http://alexeypetrushin.github.com/vfs"

namespace :docs do
  desc "Generate documentation"
  task :generate do
    %x(cd docs && docco -o site *.rb)
  end

  desc "Publish documentation"
  task :publish do
    require 'open3'
    require 'vfs'

    executor = Class.new do
      def run cmd, expectation = nil
        stdin, stdout, stderr = Open3.popen3 cmd
        stderr = stderr.read
        stdout = stdout.read

        if expectation and (stdout + stderr) !~ expectation
          puts stdout
          puts stderr
          raise "can't execute '#{cmd}'!"
        end
        stdout
      end
    end.new

    out = executor.run "git status", /nothing to commit .working directory clean/

    '.'.to_dir.tmp do |tmp|
      tmp.delete
      "docs/site".to_dir.copy_to tmp['site']

      executor.run "git checkout gh-pages", /Switched to branch 'gh-pages'/
      tmp['site'].copy_to '.'.to_dir
      executor.run "git add ."
      executor.run "git commit -a -m 'upd docs'", /upd docs/
      executor.run "git push", /gh-pages -> gh-pages/
      executor.run "git checkout master", /Switched to branch 'master'/
    end
  end
end