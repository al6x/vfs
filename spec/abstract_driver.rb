require 'spec_helper'

shared_examples_for 'abstract driver' do
  spec_dir "#{File.dirname __FILE__}/abstract_driver"
  with_tmp_spec_dir
  
  describe "file operations" do    
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
  
  # it 'smoke' do
  #   @driver.exec('ls /')
  # end
  
end