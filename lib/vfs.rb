module Vfs
  autoload :Path,           'vfs/path'
  autoload :Error,          'vfs/error'

  autoload :Entry,          'vfs/entries/entry'
  autoload :File,           'vfs/entries/file'
  autoload :Dir,            'vfs/entries/dir'
  autoload :UniversalEntry, 'vfs/entries/universal_entry'

  autoload :EntryProxy,     'vfs/entry_proxy'

  module Drivers
    autoload :Local, 'vfs/drivers/local'
  end
end

require 'vfs/vfs'
require 'vfs/integration'