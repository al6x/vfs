require 'storages/abstract'

describe Vfs::Storages::Local do
  it_should_behave_like "abstract storage"    
    
  before :each do
    @storage = Vfs::Storages::Local.new
  end
end