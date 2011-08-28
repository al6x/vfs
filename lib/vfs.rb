require 'fileutils'
require 'set'

%w(
  path
  error

  entries/entry
  entries/file
  entries/dir
  entries/universal_entry

  entry_proxy

  drivers/local

  integration

  vfs
).each{|f| require "vfs/#{f}"}