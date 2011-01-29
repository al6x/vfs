require 'abstract_driver'
require 'yaml'

describe Rsh::Drivers::Ssh do
  it_should_behave_like "abstract driver"    

  before :each do
    @driver = Rsh::Drivers::Ssh.new config[:remote_driver]
    @local_file = "#{spec_dir}/local_file"
    @check_file = "#{spec_dir}/check_file"
    
    @remote_tmp_dir = @driver.generate_tmp_dir_name    
    @remote_file = "#{@remote_tmp_dir}/remote_file"
    
    @driver.open_connection
    @driver.remove_directory @remote_tmp_dir if @driver.directory_exist? @remote_tmp_dir
    @driver.create_directory @remote_tmp_dir
  end
  
  after :each do
    @driver.remove_directory @remote_tmp_dir if @driver.directory_exist? @remote_tmp_dir
    @driver.close_connection
  end  
end