require 'abstract_driver'

describe Rsh::Drivers::Local do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Rsh::Drivers::Local.new
  end
end