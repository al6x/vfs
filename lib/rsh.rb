raise 'ruby 1.9.2 or higher required!' if RUBY_VERSION < '1.9.2'

require 'rsh/gems'

require 'open3'

require 'net/ssh'
require 'net/sftp'

%w(
  support

  drivers/abstract
  drivers/local
  drivers/ssh

  box
).each{|f| require "rsh/#{f}"}