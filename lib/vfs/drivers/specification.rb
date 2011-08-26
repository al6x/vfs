require 'rspec_ext'
require 'ruby_ext'

shared_examples_for 'vfs driver basic' do
  it 'should respond to :local?' do
    @driver.should respond_to(:local?)
  end

  it "should provide open method" do
    @driver.open
    @driver.open{'result'}.should == 'result'
  end
end

shared_examples_for 'vfs driver attributes basic' do
  it 'should have root dir' do
    attrs = @driver.attributes('/')
    attrs[:dir].should  be_true
    attrs[:file].should be_false
  end

  it "attributes should return nil if there's no entry" do
    @driver.attributes('/non_existing_entry').should be_nil
  end
end

shared_examples_for 'vfs driver files' do
  it "file attributes" do
    @driver.attributes('/file').should be_nil

    @driver.write_file('/file', false){|w| w.write 'something'}
    attrs = @driver.attributes('/file')
    attrs[:file].should be_true
    attrs[:dir].should  be_false
  end

  it "read, write, append" do
    # write
    @driver.write_file('/file', false){|w| w.write 'something'}
    @driver.attributes('/file')[:file].should == true

    # read
    data = ""
    @driver.read_file('/file'){|buff| data << buff}
    data.should == 'something'

    # append
    @driver.write_file('/file', true){|w| w.write ' another'}
    data = ""
    @driver.read_file('/file'){|buff| data << buff}
    data.should == 'something another'
  end

  it "delete_file" do
    @driver.write_file('/file', false){|w| w.write 'something'}
    @driver.attributes('/file')[:file].should be_true
    @driver.delete_file('/file')
    @driver.attributes('/file').should be_nil
  end
end

shared_examples_for 'vfs driver full attributes for files' do
  it "attributes for files" do
    @driver.write_file('/file', false){|w| w.write 'something'}
    attrs = @driver.attributes('/file')
    attrs[:file].should be_true
    attrs[:dir].should  be_false
    attrs[:created_at].class.should == Time
    attrs[:updated_at].class.should == Time
    attrs[:size].should == 9
  end
end

shared_examples_for 'vfs driver dirs' do
  it "directory crud" do
    @driver.attributes('/dir').should be_nil

    @driver.create_dir('/dir')
    attrs = @driver.attributes('/dir')
    attrs[:file].should be_false
    attrs[:dir].should  be_true

    @driver.delete_dir('/dir')
    @driver.attributes('/dir').should be_nil
  end

  it 'should delete not-empty directories' do
    @driver.create_dir('/dir')
    @driver.create_dir('/dir/dir2')
    @driver.write_file('/dir/dir2/file', false){|w| w.write 'something'}
    @driver.attributes('/dir').should_not be_nil

    @driver.delete_dir('/dir')
    @driver.attributes('/dir').should be_nil
  end

  it 'each' do
    -> {@driver.each_entry('/not_existing_dir', nil){|path, type| list[path] = type}}.should raise_error

    @driver.create_dir '/dir'
    @driver.create_dir('/dir/dir2')
    @driver.write_file('/dir/file', false){|w| w.write 'something'}

    list = {}
    @driver.each_entry '/dir', nil do |path, type|
      type = type.call if type.is_a? Proc
      list[path] = type
    end

    list.should == {'dir2' => :dir, 'file' => :file}
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

shared_examples_for 'vfs driver query' do
  it 'each with query' do
    @driver.create_dir '/dir'
    @driver.create_dir('/dir/dir_a')
    @driver.create_dir('/dir/dir_b')
    @driver.write_file('/dir/file_a', false){|w| w.write 'something'}

    list = {}
    @driver.each_entry '/dir', '*_a' do |path, type|
      type = type.call if type.is_a? Proc
      list[path] = type
    end

    list.should == {'dir_a' => :dir, 'file_a' => :file}
  end
end

shared_examples_for 'vfs driver full attributes for dirs' do
  it "attributes for dirs" do
    @driver.create_dir('/dir')
    attrs = @driver.attributes('/dir')
    attrs[:file].should be_false
    attrs[:dir].should  be_true
    attrs[:created_at].class.should == Time
    attrs[:updated_at].class.should == Time
    attrs.should_not include(:size)
  end
end

shared_examples_for 'vfs driver tmp dir' do
  it "tmp dir" do
    dir = @driver.tmp
    @driver.attributes(dir).should_not be_nil
    @driver.delete_dir dir
    @driver.attributes(dir).should be_nil

    dir = nil
    @driver.tmp do |tmp_dir|
      dir = tmp_dir
      @driver.attributes(dir).should_not be_nil
    end
    @driver.attributes(dir).should be_nil
  end
end