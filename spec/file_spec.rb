require 'spec_helper'

describe 'File' do
  with_test_dir

  before do
    @path = test_dir['a/b/c']
  end

  describe 'existence' do
    it "should check only files" do
      @path.should_not exist
      @path.dir.create
      @path.should be_dir
      @path.file.should_not exist
      @path.file.create
      @path.should be_file
      @path.file.should exist
    end
  end

  describe 'read' do
    it 'should raise error if not exist' do
      -> {@path.read}.should raise_error(Vfs::Error, /not exist/)
      -> {@path.read{|buff|}}.should raise_error(Vfs::Error, /not exist/)
    end

    it 'should not raise error in silent mode' do
      @path.read(bang: false).should == ''
      data = ""; @path.read(bang: false){|buff| data << buff}; data.should == ''
    end

    it "reading" do
      @path.write('something')

      @path.read.should == 'something'
      @path.read(bang: false).should == 'something'
      data = ""; @path.read{|buff| data << buff}; data.should == 'something'
    end

    # it 'content' do
    #   @path.write('something')
    #   @path.content.should == 'something'
    # end
  end

  describe 'creation' do
    it 'create' do
      file = @path.file

      file.should_receive(:write).with('', {})
      file.create
    end

    it 'should be chainable' do
      @path.file.create.should == @path
    end
  end

  describe 'write' do
    it 'should create parent dirs if not exists' do
      @path.parent.should_not exist
      @path.write 'something'
      @path.read.should == 'something'
    end

    it 'should write empty file' do
      @path.write
      @path.read.should == ''
    end

    it 'should override existing file' do
      @path.write 'something'
      @path.should be_file
      @path.write 'other'
      @path.read.should == 'other'
    end

    it 'should override existing dir' do
      @path.dir.create
      @path.should be_dir
      @path.write 'another'
      @path.read.should == 'another'
    end

    it 'writing' do
      @path.write 'something'
      @path.read.should == 'something'

      @path.write do |writer|
        writer.write 'another'
      end
      @path.read.should == 'another'
    end

    it 'append' do
      file = @path.file
      file.should_receive(:write).with('something', append: true)
      file.append 'something'
    end

    it 'should correctly display errors (from error)' do
      -> {test_dir['test'].write{|writer| raise 'some error'}}.should raise_error(/some error/)
    end
  end

  it 'update' do
    @path.write 'something'
    @path.update do |data|
      data.should == 'something'
      'another'
    end
    @path.read.should == 'another'
  end

  describe 'copying' do
    before do
      @from = @path.file
      @from.write('something')
    end

    it 'should not copy to itself' do
      -> {@from.copy_to @from}.should raise_error(Vfs::Error, /itself/)
    end

    def check_copy_for to
      target = @from.copy_to to
      target.read.should == 'something'
      target.should == to

      # overriding
      @from.write 'another'
      target = @from.copy_to to
      target.read.should == 'another'
      target.should == to
    end

    it 'should copy to file (and overwrite)' do
      check_copy_for test_dir.file('to')
    end

    it 'should copy to dir (and overwrite)' do
      check_copy_for test_dir.dir("to")
    end

    it 'should copy to UniversalEntry (and overwrite)' do
      check_copy_for test_dir.entry('to')
    end

    it 'should be chainable' do
      to = test_dir['to']
      @from.copy_to(to).should == to
    end

    it "should autocreate parent's path if not exist (from error)" do
      to = test_dir['parent_path/to']
      @from.copy_to(to)
      to.read.should == 'something'
    end
  end

  describe 'moving' do
    it 'move_to' do
      from, to = @path.file('from'), @path.file('to')
      from.should_receive(:copy_to).with(to)
      from.should_receive(:delete).with()
      from.move_to to
    end

    it 'should be chainable' do
      from, to = @path.file('from').create, @path.file('to')
      from.move_to(to).should == to
    end
  end

  describe 'deleting' do
    it "should not raise error if it's trying to delete a dir" do
      @path.dir.create
      @path.file.delete
      @path.entry.should_not exist
    end

    it "shouldn't raise if file not exist" do
      @path.file.delete
    end

    it 'should be chainable' do
      @path.file.delete.should == @path
    end
  end

  describe "extra stuff" do
    it 'render' do
      template = test_dir / 'letter.erb'
      template.write "Hello dear <%= name %>"
      template.render(name: 'Mary').should == "Hello dear Mary"
    end

    begin
      require 'haml'

      it 'render using other template engines' do
        template = test_dir / 'letter.haml'
        template.write "Hello dear \#{name}"
        template.render(name: 'Mary').should =~ /Hello dear Mary/
      end
    rescue LoadError
      warn "no :haml template engine, skipping rendering with haml specs"
    end

    it 'size' do
      @path.file.write('data').size.should == 4
    end
  end
end