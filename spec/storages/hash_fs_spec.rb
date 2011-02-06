require 'storages/abstract'

describe Vfs::Storages::HashFs do
  it_should_behave_like "abstract storage"    
    
  before :each do
    @storage = Vfs::Storages::HashFs.new
  end
end