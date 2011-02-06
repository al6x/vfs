require 'rspec_ext'
require 'ruby_ext'

require 'vfs/storages/local'
require 'vfs/storages/specification'

describe Vfs::Storages::Local do
  it_should_behave_like "abstract storage"    
    
  before :each do
    @storage = Vfs::Storages::Local.new
  end
end