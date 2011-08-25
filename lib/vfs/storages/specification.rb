require 'rspec_ext'
require 'ruby_ext'

shared_examples_for 'vfs storage basic' do
  before do
    @tmp_dir = @storage.open_fs{|fs| fs.tmp}
  end

  after do
    @storage.open_fs{|fs| fs.delete_dir @tmp_dir if fs.attributes(@tmp_dir)[:dir]}
  end

  it 'should respond to :local?' do
    @storage.open_fs{|fs| fs.should respond_to(:local?)}
  end

  it 'should have root dir' do
    @storage.open_fs do |fs|
      fs.attributes('/').subset(:file, :dir).should == {file: false, dir: true}
    end
  end
end

shared_examples_for 'vfs storage files' do
  before do
    @tmp_dir = @storage.open_fs{|fs| fs.tmp}
  end

  after do
    @storage.open_fs{|fs| fs.delete_dir @tmp_dir if fs.attributes(@tmp_dir)[:dir]}
  end

  before do
    @remote_file = "#{@tmp_dir}/remote_file"
  end

  it "file attributes" do
    @storage.open_fs do |fs|
      fs.attributes(@remote_file).should == {file: false, dir: false}
      fs.write_file(@remote_file, false){|w| w.write 'something'}
      attrs = fs.attributes(@remote_file)
      fs.attributes(@remote_file).subset(:file, :dir).should == {file: true, dir: false}
    end
  end

  it "read, write & append" do
    @storage.open_fs do |fs|
      fs.write_file(@remote_file, false){|w| w.write 'something'}
      fs.attributes(@remote_file)[:file].should be_true

      data = ""
      fs.read_file(@remote_file){|buff| data << buff}
      data.should == 'something'

      # append
      fs.write_file(@remote_file, true){|w| w.write ' another'}
      data = ""
      fs.read_file(@remote_file){|buff| data << buff}
      data.should == 'something another'
    end
  end

  it "delete_file" do
    @storage.open_fs do |fs|
      fs.write_file(@remote_file, false){|w| w.write 'something'}
      fs.attributes(@remote_file)[:file].should be_true
      fs.delete_file(@remote_file)
      fs.attributes(@remote_file).should == {file: false, dir: false}
    end
  end
end

shared_examples_for 'vfs storage dirs' do
  before do
    @tmp_dir = @storage.open_fs{|fs| fs.tmp}
    @remote_dir = "#{@tmp_dir}/some_dir"
  end

  after do
    @storage.open_fs{|fs| fs.delete_dir @tmp_dir if fs.attributes(@tmp_dir)[:dir]}
  end

  it "directory_exist?, create_dir, delete_dir" do
    @storage.open_fs do |fs|
      fs.attributes(@remote_dir).should == {file: false, dir: false}
      fs.create_dir(@remote_dir)
      fs.attributes(@remote_dir).subset(:file, :dir).should == {file: false, dir: true}
      fs.delete_dir(@remote_dir)
      fs.attributes(@remote_dir).should == {file: false, dir: false}
    end
  end

  it 'should delete not-empty directories' do
    @storage.open_fs do |fs|
      fs.create_dir(@remote_dir)
      fs.create_dir("#{@remote_dir}/dir")
      fs.write_file("#{@remote_dir}/dir/file", false){|w| w.write 'something'}
      fs.delete_dir(@remote_dir)
      fs.attributes(@remote_dir).should == {file: false, dir: false}
    end
  end

  it 'each' do
    @storage.open_fs do |fs|
      list = {}
      fs.each_entry(@tmp_dir, nil){|path, type| list[path] = type}
      list.should be_empty

      dir, file = "#{@tmp_dir}/dir", "#{@tmp_dir}/file"
      fs.create_dir(dir)
      fs.write_file(file, false){|w| w.write 'something'}

      list = {}
      fs.each_entry(@tmp_dir, nil){|path, type| list[path] = type}
      list.should == {'dir' => :dir, 'file' => :file}
    end
  end

  # it "upload_directory & download_directory" do
  #   upload_path_check = "#{@remote_path}/dir2/file"
  #   check_attributes upload_path_check, nil
  #   fs.upload_directory(@from_local, @remote_path)
  #   check_attributes upload_path_check, file: true, dir: false
  #
  #   download_path_check = "#{@to_local}/dir2/file"
  #   File.exist?(download_path_check).should be_false
  #   fs.download_directory(@remote_path, @to_local)
  #   File.exist?(download_path_check).should be_true
  # end
end