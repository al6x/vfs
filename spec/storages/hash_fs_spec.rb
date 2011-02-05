require 'storages/abstract'

describe Vfs::Storages::HashFs do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Vfs::Storages::HashFs.new
  end
end