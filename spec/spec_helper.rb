require 'rspec_ext'
require 'ruby_ext'

require 'tilt'
require 'vfs'

require 'fakefs/spec_helpers'


# 
# FakeFS fixes
# 
FakeFS::File::Stat.class_eval do
  # there's also file? method defined on File::Stat
  def file?; !directory? end
end