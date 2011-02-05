require 'drivers/abstract'
require 'vfs/drivers/hash_fs'

describe Vfs::Drivers::HashFs do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Vfs::Drivers::HashFs.new
  end
end