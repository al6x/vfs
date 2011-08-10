%w(
  support

  path
  error

  entries/entry/special_attributes
  entries/entry
  entries/file
  entries/dir
  entries/universal_entry

  entry_proxy

  storages/local

  integration/string

  vfs
).each{|f| require "vfs/#{f}"}