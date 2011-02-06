require 'rspec_ext'
require 'ruby_ext'

require 'vfs/storages/hash_fs'
require 'vfs/storages/specification'

describe Vfs::Storages::HashFs do
  it_should_behave_like "abstract storage"    
    
  before :each do
    @storage = Vfs::Storages::HashFs.new
  end
end