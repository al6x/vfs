shared_examples_for 'abstract storage' do  
  def clean_tmp_dir
    attrs = @storage.attributes(@tmp_dir)
    @storage.delete_dir @tmp_dir if attrs && attrs[:dir]
  end    
  
  before :each do
    @tmp_dir = @storage.tmp
  end

  after :each do
    clean_tmp_dir
  end
  
  it 'should have root dir' do    
    @storage.attributes('/').should_not be_nil
    @storage.attributes('/').subset(:file, :dir).should == {file: false, dir: true}
  end
    
  describe "files" do  
    before :each do
      @remote_file = "#{@tmp_dir}/remote_file"
    end
    
    it "file attributes" do
      @storage.attributes(@remote_file).should == nil
      @storage.write_file(@remote_file, false){|w| w.call 'something'}
      attrs = @storage.attributes(@remote_file)      
      @storage.attributes(@remote_file).subset(:file, :dir).should == {file: true, dir: false}
    end

    it "read, write & append" do
      @storage.write_file(@remote_file, false){|w| w.call 'something'}
      @storage.attributes(@remote_file)[:file].should be_true
      
      data = ""  
      @storage.read_file(@remote_file){|buff| data << buff}
      data.should == 'something'
      
      # append
      @storage.write_file(@remote_file, true){|w| w.call ' another'}
      data = ""  
      @storage.read_file(@remote_file){|buff| data << buff}
      data.should == 'something another'
    end
  
    it "delete_file" do
      @storage.write_file(@remote_file, false){|w| w.call 'something'}        
      @storage.attributes(@remote_file)[:file].should be_true
      @storage.delete_file(@remote_file)
      @storage.attributes(@remote_file).should be_nil
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
      @storage.attributes(@remote_dir).should be_nil
      @storage.create_dir(@remote_dir)
      @storage.attributes(@remote_dir).subset(:file, :dir).should == {file: false, dir: true}
      @storage.delete_dir(@remote_dir)
      @storage.attributes(@remote_dir).should be_nil
    end
    
    it 'each' do
      list = {}
      @storage.each(@tmp_dir){|path, type| list[path] = type}
      list.should be_empty
      
      dir, file = "#{@tmp_dir}/dir", "#{@tmp_dir}/file"
      @storage.create_dir(dir)
      @storage.write_file(file, false){|w| w.call 'something'}
      
      list = {}
      @storage.each(@tmp_dir){|path, type| list[path] = type}
      list.should == {'dir' => :dir, 'file' => :file}
    end
  
    # it "upload_directory & download_directory" do
    #   upload_path_check = "#{@remote_path}/dir2/file"
    #   check_attributes upload_path_check, nil        
    #   @storage.upload_directory(@from_local, @remote_path)
    #   check_attributes upload_path_check, file: true, dir: false
    #   
    #   download_path_check = "#{@to_local}/dir2/file"
    #   File.exist?(download_path_check).should be_false
    #   @storage.download_directory(@remote_path, @to_local)
    #   File.exist?(download_path_check).should be_true
    # end
  end  
end