require 'abstract_driver'
require 'yaml'

describe Vfs::Drivers::Ssh do
  it_should_behave_like "abstract driver"    

  before :each do
    @driver = Vfs::Drivers::Ssh.new config[:remote_driver]
    @driver.open
  end
  
  after :each do
    @driver.close
  end  
end