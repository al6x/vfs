require 'spec_helper'

shared_examples_for 'abstract driver' do
  dir = "#{File.dirname __FILE__}/abstract_driver"
  with_tmp_spec_dir dir, before: :each
  
  describe "file operations" do    
    before :each do
      @local_file = "#{spec_dir}/local_file"
      @check_file = "#{spec_dir}/check_file"

      @remote_dir = @driver.generate_tmp_dir_name    
      @remote_file = "#{@remote_dir}/remote_file"
      
      @driver.remove_directory @remote_dir if @driver.directory_exist? @remote_dir
      @driver.create_directory @remote_dir
    end

    after :each do
      @driver.remove_directory @remote_dir if @driver.directory_exist? @remote_dir
    end
    
    it "file_exist?" do
      @driver.file_exist?(@remote_file).should be_false
      @driver.upload_file(@local_file, @remote_file)
      @driver.file_exist?(@remote_file).should be_true
    end

    it "upload & download file" do
      @driver.upload_file(@local_file, @remote_file)
      @driver.file_exist?(@remote_file).should be_true
      
      @driver.download_file(@remote_file, @check_file)
      File.read(@local_file).should == File.read(@check_file)
    end
    
    it "remove_file" do
      @driver.upload_file(@local_file, @remote_file)
      @driver.file_exist?(@remote_file).should be_true
      @driver.remove_file(@remote_file)
      @driver.file_exist?(@remote_file).should be_false
    end    
  end  
  
  describe "shell" do
    it 'exec' do
      @driver.exec("echo 'ok'").should == [0, "ok\n", ""]
    end  
  end
end