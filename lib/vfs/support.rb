require 'fileutils'
require 'net/ssh'
require 'net/sftp'

# class File
#   class << self
#     def ensure_dir_exist directory, options = {}       
#       options = options.symbolize_keys 
#       clean = options.delete :clean
#       raise "unsupported options #{options.keys}!" unless options.empty?
#     
#       FileUtils.rm_r directory, :force => true if clean and File.exist?(directory)
#       FileUtils.mkdir_p directory
#     end
#   
#     def copy_dir_content from, to
#       Dir.glob "#{from}/*" do |item|
#         FileUtils.cp_r item, to
#       end
#     end
#     
#     def copy_dir from, to
#       FileUtils.cp_r from, to
#     end
#     
#     def remove_dir dir
#       FileUtils.rm_r dir
#     end
#   end
# end