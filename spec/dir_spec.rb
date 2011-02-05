require 'base'

describe 'Dir' do
  before :each do
    @fs = '/'.to_fs_on(Vfs::Storages::HashFs.new)
    @path = @fs['/a/b/c']
  end
  
  describe 'existence' do
    it "should check only dirs" do
      @path.should_not exist
      @path.file.create
      @path.should be_file
      @path.dir.should_not exist
      @path.dir.create!
      @path.should be_dir
      @path.dir.should exist
    end
  end
    
  it "should not respond to read and write methods" do
    -> {@path.dir.read}.should raise_error(NoMethodError)
    -> {@path.dir.write}.should raise_error(NoMethodError)
  end
  
  describe 'create' do
    it 'should be chainable' do
      @path.dir.create.should == @path
      @path.dir.create!.should == @path
    end
    
    it 'should create parent dirs if not exists' do
      @path.parent.should_not exist
      @path.dir.create
      @path.should be_dir
    end
    
    it 'should override existing file if override specified' do
      @path.file.create
      @path.should be_file
      -> {@path.dir.create}.should raise_error(Vfs::Error, /exist/)
      @path.dir.create!
      @path.should be_dir
    end
    
    it 'should override existing dir if override specified' do
      @path.dir.create
      @path.should be_dir
      -> {@path.dir.create}.should raise_error(Vfs::Error, /exist/)
      @path.dir.create!
      @path.should be_dir
    end
  end
  
  describe 'destroying' do
    it "should raise error if it's trying to destroy a file (unless force specified)" do
      @path.file.create
      -> {@path.dir.destroy}.should raise_error(Vfs::Error, /can't destroy File/)
      @path.dir.destroy!
      @path.entry.should_not exist
    end
    
    it "shouldn't raise if dir not exist" do
      @path.dir.destroy
    end
    
    it 'should be chainable' do
      @path.dir.destroy.should == @path
      @path.dir.destroy!.should == @path
    end
  end
  
  describe 'content' do
    before :each do
      @path.dir('dir').create
      @path.dir('dir/another_dir').create
      @path.file('file').create      
    end
    
    it 'entries' do
      -> {@path['non_existing'].entries}.should raise_error(Vfs::Error, /not exist/)
      @path['non_existing'].entries(bang: false).should == []
      @path.entries.to_set.should be_eql([@path.dir('dir'), @path.file('file')].to_set)
      list = []
      @path.entries{|e| list << e}
      list.to_set.should be_eql([@path.dir('dir'), @path.file('file')].to_set)
    end
    
    it 'files' do
      @path.files.should be_eql([@path.file('file')])
    end
    
    it 'dirs' do
      @path.dirs.should be_eql([@path.dir('dir')])
    end
    
    it 'has? & include?'
  end
  
  it 'copy'
    
  describe 'moving' do
    it 'move_to' do
      from, to = @path.file('from'), @path.file('to')
      from.should_receive(:copy_to).with(to, {})
      from.should_receive(:destroy).with({})
      from.move_to to
    
      from.should_receive(:move_to).with(to, override: true)
      from.move_to! to
    end
    
    it 'should be chainable' do
      pending
      # from, to = @path.dir('from'), @path.dir('to')
      # from.move_to(from).should == to['from']
      # from.move_to!(from).should == to['from']
    end
  end
end