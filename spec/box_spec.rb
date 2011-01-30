require 'spec_helper'

describe Rsh::Box do  
  with_tmp_spec_dir before: :each
  
  before :each do
    @box = Rsh::Box.new

    @local_dir = spec_dir    
    @remote_dir = @box.generate_tmp_dir_name        
    
    @box.remove_directory @remote_dir if @box.directory_exist? @remote_dir
    @box.create_directory @remote_dir
  end

  after :each do
    @box.remove_directory @remote_dir if @box.directory_exist? @remote_dir
  end
  
  describe "io" do
    describe "files" do
      before :each do
        @local_file = "#{@local_dir}/local_file"
        @check_file = "#{@local_dir}/check_file"
        @remote_file = "#{@remote_dir}/remote_file"
      end
      
      it "file_exist?" do
        @box.file_exist?(@remote_file).should be_false
        @box.upload_file(@local_file, @remote_file)
        @box.file_exist?(@remote_file).should be_true
      end

      it "upload_file" do
        @box.upload_file(@local_file, @remote_file)
        @box.file_exist?(@remote_file).should be_true

        lambda{@box.upload_file(@local_file, @remote_file)}.should raise_error(/exists/)

        # upload with override
        @box.upload_file(@local_file, @remote_file, override: true)
        @box.file_exist?(@remote_file).should be_true
      end

      it "download_file" do
        lambda{@box.download_file(@remote_file, @check_file)}.should raise_error(/not exists/)
        @box.upload_file(@local_file, @remote_file)
        @box.download_file(@remote_file, @check_file)
        File.read(@local_file).should == File.read(@check_file)
      end          

      it "remove_file" do
        lambda{@box.remove_file(@remote_file)}.should raise_error(/not exists/)
        @box.upload_file(@local_file, @remote_file)
        @box.file_exist?(@remote_file).should be_true
        @box.remove_file(@remote_file)
        @box.file_exist?(@remote_file).should be_false
      end
    end
    
    describe 'directories' do
      before :each do 
        @from_local, @remote_path, @to_local = "#{@local_dir}/dir", "#{@remote_dir}/upload", "#{@local_dir}/download"
      end
      
      it "directory_exist?" do
        @box.file_exist?(@remote_path).should be_false
        @box.upload_directory(@from_local, @remote_path)
        @box.file_exist?(@remote_path).should be_true
      end

      it "upload_directory" do
        @box.upload_directory(@from_local, @remote_path)
        @box.directory_exist?(@remote_path).should be_true
    
        lambda{@box.upload_directory(@from_local, @remote_path)}.should raise_error(/exists/)
    
        # upload with override
        @box.upload_directory(@from_local, @remote_path, override: true)
        @box.directory_exist?(@remote_path).should be_true
      end
    
      it "download_directory" do
        lambda{@box.download_directory(@remote_path, @to_local)}.should raise_error(/not exists/)
        @box.upload_directory(@from_local, @remote_path)
        @box.download_directory(@remote_path, @to_local)
        File.exist?("#{@to_local}/dir2/file").should be_true
      end          
    
      it "remove_directory" do
        lambda{@box.remove_directory(@remote_path)}.should raise_error(/not exists/)
        @box.upload_directory(@from_local, @remote_path)
        @box.directory_exist?(@remote_path).should be_true
        @box.remove_directory(@remote_path)
        @box.directory_exist?(@remote_path).should be_false
      end    
    end
  end
  
  describe "shell" do
    it 'exec' do
      @box.bash("echo 'ok'").should == ["ok\n", ""]
    end  
  end
end