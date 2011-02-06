require 'vfs/storages/local'
require 'vfs/storages/specification'

describe Vfs::Storages::Local do
  it_should_behave_like "vfs storage"    
    
  before :each do
    @storage = Vfs::Storages::Local.new
  end
end