require 'abstract_driver'

describe Rsh::Drivers::Local do
  it_should_behave_like "abstract driver"      
  
  before :each do
    @driver = Rsh::Drivers::Local.new
    @local_file = "#{spec_dir}/local_file"
    @remote_file = "#{spec_dir}/remote_file"
    @check_file = "#{spec_dir}/check_file"
  end
end