require 'abstract_driver'
require 'yaml'

describe Rsh::Drivers::Ssh do
  it_should_behave_like "abstract driver"    

  before :each do
    @driver = Rsh::Drivers::Ssh.new config[:remote_driver]
    @driver.open_connection
  end
  
  after :each do
    @driver.close_connection
  end  
end