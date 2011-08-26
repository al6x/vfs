require 'rspec_ext'
require 'ruby_ext'

shared_examples_for 'vfs storage basic' do
  it 'should respond to :local?' do
    @storage.should respond_to(:local?)
  end

  it "should provide open method" do
    @storage.open
    @storage.open{'result'}.should == 'result'
  end
end

shared_examples_for 'vfs storage attributes basic' do
  it 'should have root dir' do
    attrs = @storage.attributes('/')
    attrs[:dir].should  be_true
    attrs[:file].should be_false
  end

  it "attributes should return nil if there's no entry" do
    @storage.attributes('/non_existing_entry').should be_nil
  end
end

shared_examples_for 'vfs storage files' do
  it "file attributes" do
    @storage.attributes('/file').should be_nil

    @storage.write_file('/file', false){|w| w.write 'something'}
    attrs = @storage.attributes('/file')
    attrs[:file].should be_true
    attrs[:dir].should  be_false
  end

  it "read, write, append" do
    # write
    @storage.write_file('/file', false){|w| w.write 'something'}
    @storage.attributes('/file')[:file].should == true

    # read
    data = ""
    @storage.read_file('/file'){|buff| data << buff}
    data.should == 'something'

    # append
    @storage.write_file('/file', true){|w| w.write ' another'}
    data = ""
    @storage.read_file('/file'){|buff| data << buff}
    data.should == 'something another'
  end

  it "delete_file" do
    @storage.write_file('/file', false){|w| w.write 'something'}
    @storage.attributes('/file')[:file].should be_true
    @storage.delete_file('/file')
    @storage.attributes('/file').should be_nil
  end
end

shared_examples_for 'vfs storage full attributes for files' do
  it "attributes for files" do
    @storage.write_file('/file', false){|w| w.write 'something'}
    attrs = @storage.attributes('/file')
    attrs[:file].should be_true
    attrs[:dir].should  be_false
    attrs[:created_at].class.should == Time
    attrs[:updated_at].class.should == Time
    attrs[:size].should == 9
  end
end

shared_examples_for 'vfs storage dirs' do
  it "directory crud" do
    @storage.attributes('/dir').should be_nil

    @storage.create_dir('/dir')
    attrs = @storage.attributes('/dir')
    attrs[:file].should be_false
    attrs[:dir].should  be_true

    @storage.delete_dir('/dir')
    @storage.attributes('/dir').should be_nil
  end

  it 'should delete not-empty directories' do
    @storage.create_dir('/dir')
    @storage.create_dir('/dir/dir2')
    @storage.write_file('/dir/dir2/file', false){|w| w.write 'something'}
    @storage.attributes('/dir').should_not be_nil

    @storage.delete_dir('/dir')
    @storage.attributes('/dir').should be_nil
  end

  it 'each' do
    -> {@storage.each_entry('/not_existing_dir', nil){|path, type| list[path] = type}}.should raise_error

    @storage.create_dir '/dir'
    @storage.create_dir('/dir/dir2')
    @storage.write_file('/dir/file', false){|w| w.write 'something'}

    list = {}
    @storage.each_entry '/dir', nil do |path, type|
      type = type.call if type.is_a? Proc
      list[path] = type
    end

    list.should == {'dir2' => :dir, 'file' => :file}
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

shared_examples_for 'vfs storage query' do
  it 'each with query' do
    @storage.create_dir '/dir'
    @storage.create_dir('/dir/dir_a')
    @storage.create_dir('/dir/dir_b')
    @storage.write_file('/dir/file_a', false){|w| w.write 'something'}

    list = {}
    @storage.each_entry '/dir', '*_a' do |path, type|
      type = type.call if type.is_a? Proc
      list[path] = type
    end

    list.should == {'dir_a' => :dir, 'file_a' => :file}
  end
end

shared_examples_for 'vfs storage full attributes for dirs' do
  it "attributes for dirs" do
    @storage.create_dir('/dir')
    attrs = @storage.attributes('/dir')
    attrs[:file].should be_false
    attrs[:dir].should  be_true
    attrs[:created_at].class.should == Time
    attrs[:updated_at].class.should == Time
    attrs.should_not include(:size)
  end
end

shared_examples_for 'vfs storage tmp dir' do
  it "tmp dir" do
    dir = @storage.tmp
    @storage.attributes(dir).should_not be_nil
    @storage.delete_dir dir
    @storage.attributes(dir).should be_nil

    dir = nil
    @storage.tmp do |tmp_dir|
      dir = tmp_dir
      @storage.attributes(dir).should_not be_nil
    end
    @storage.attributes(dir).should be_nil
  end
end