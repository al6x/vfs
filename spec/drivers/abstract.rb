require 'drivers/base'

shared_examples_for 'abstract driver' do  
  def clean_tmp_dir
    attrs = @driver.attributes(@tmp_dir)
    @driver.delete_dir @tmp_dir if attrs && attrs[:dir]
  end    
  
  before :each do
    @tmp_dir = @driver.tmp
  end

  after :each do
    clean_tmp_dir
  end
    
  describe "files" do  
    before :each do
      @remote_file = "#{@tmp_dir}/remote_file"
    end
    
    it "file attributes" do
      @driver.attributes(@remote_file).should == nil
      @driver.write_file(@remote_file){|w| w.call 'some content'}
      attrs = @driver.attributes(@remote_file)      
      @driver.attributes(@remote_file).subset(:file, :dir).should == {file: true, dir: false}
    end

    it "upload & download file" do
      @driver.write_file(@remote_file){|w| w.call 'some content'}
      @driver.attributes(@remote_file)[:file].should be_true
      
      data = ""  
      @driver.read_file(@remote_file){|buff| data << buff}
      data.should == 'some content'
    end
  
    it "delete_file" do
      @driver.write_file(@remote_file){|w| w.call 'some content'}        
      @driver.attributes(@remote_file)[:file].should be_true
      @driver.delete_file(@remote_file)
      @driver.attributes(@remote_file).should be_nil
    end
  end
  
  describe 'directories' do
    # before :each do
    #   @from_local, @remote_path, @to_local = "#{@local_dir}/dir", "#{@tmp_dir}/upload", "#{@local_dir}/download"
    # end
    
    before :each do
      @remote_dir = "#{@tmp_dir}/some_dir"
    end
    
    it "directory_exist?, create_dir, delete_dir" do        
      @driver.attributes(@remote_dir).should be_nil
      @driver.create_dir(@remote_dir)
      @driver.attributes(@remote_dir).subset(:file, :dir).should == {file: false, dir: true}
      @driver.delete_dir(@remote_dir)
      @driver.attributes(@remote_dir).should be_nil
    end
  
    # it "upload_directory & download_directory" do
    #   upload_path_check = "#{@remote_path}/dir2/file"
    #   check_attributes upload_path_check, nil        
    #   @driver.upload_directory(@from_local, @remote_path)
    #   check_attributes upload_path_check, file: true, dir: false
    #   
    #   download_path_check = "#{@to_local}/dir2/file"
    #   File.exist?(download_path_check).should be_false
    #   @driver.download_directory(@remote_path, @to_local)
    #   File.exist?(download_path_check).should be_true
    # end
  end  
end