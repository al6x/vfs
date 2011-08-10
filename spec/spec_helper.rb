require 'rspec_ext'
require 'ruby_ext'

require 'tilt'
require 'vfs'

rspec do
  def self.with_test_fs        
    before do
      @test_fs = "/tmp/test_fs".to_dir
      
      FileUtils.rm_r test_fs.path if File.exist? test_fs.path
      FileUtils.mkdir_p test_fs.path
    end
    
    after do      
      FileUtils.rm_r test_fs.path if File.exist? test_fs.path
      @test_fs = nil
    end
  end
  
  def test_fs
    @test_fs
  end
end

# require 'fakefs/spec_helpers'
# 
# include FakeFS::SpecHelpers
# use_fakefs self
# 
# 
# # 
# # FakeFS fixes
# # 
# FakeFS::File::Stat.class_eval do
#   # there's also file? method defined on File::Stat
#   def file?; !directory? end
# end
# 
# FakeFS::File.class_eval do
#   class << self
#     # File.delete should raise error if it's directory
#     alias_method :delete_without_bang, :delete
#     def delete path
#       raise Errno::EPERM, "Operation not permitted - #{path}" if directory?(path)
#       delete_without_bang path
#     end
#   end
# end