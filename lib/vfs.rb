%w(
  support

  path
  error
  
  entries/entry
  entries/file
  entries/dir
  entries/universal_entry
  
  entry_proxy
  
  storages/hash_fs
  storages/local
  
  integration/string
).each{|f| require "vfs/#{f}"}