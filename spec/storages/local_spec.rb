require 'storages/abstract'

describe Vfs::Storages::Local do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Vfs::Storages::Local.new
  end
end