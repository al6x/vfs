require 'abstract_driver'

describe Vfs::Drivers::Local do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Vfs::Drivers::Local.new
  end
end