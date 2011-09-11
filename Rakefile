require 'rake_ext'

project(
  name: "vfs",
  gem: true,
  summary: "Virtual File System - simple and unified API over different storages (Local, S3, SFTP, ...)",
  # version: '0.4.0',

  author: "Alexey Petrushin",
  homepage: "http://github.com/alexeypetrushin/vfs"
)

desc "Generate documentation"
task :docs do
  %x(cd docs && rocco -o site *.rb)
end