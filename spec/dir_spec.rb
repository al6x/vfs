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
    
    it 'should silently exit if dir already exist' do
      @path.dir.create
      @path.dir.create
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
    
    it 'has? & include?' do
      @path.include?('dir').should be_true
      @path.include?('dir/another_dir').should be_true
      @path.include?('file').should be_true
      @path.include?('non_existing').should be_false
    end
  end
  
  describe 'copying' do
    before :each do 
      @from = @path.dir
      @from.create
      @from.file('file').write 'something'
      @from.dir('dir').create.tap do |dir|
        dir.file('file2').write 'something2'        
      end
    end
    
    it 'should not copy to itself' do
      -> {@from.copy_to @from}.should raise_error(Vfs::Error, /itself/)
    end
    
    def check_copy_for to, error_re = nil
      begin
        target = @from.copy_to to                  
        target['file'].read.should == 'something'
        target['dir/file2'].read.should == 'something2'
        target.should == to
      rescue Exception => e
        raise e unless e.message =~ error_re
      end      
      
      @from['dir/file2'].write! 'another'
      -> {@from.copy_to to}.should raise_error(Vfs::Error, /exist/)
      target = @from.copy_to! to
      target['file'].read.should == 'something'
      target['dir/file2'].read.should == 'another'            
    end
    
    it 'should copy to file (and overwrite if forced)' do
      check_copy_for @fs['to'], /can't copy Dir to File/
    end
    
    it 'should copy to dir (and overwrite if forced)' do
      check_copy_for @fs['to']
    end
    
    it 'should copy to UniversalEntry (and overwrite if forced)' do
      check_copy_for @fs['to']
    end
    
    it 'should be chainable' do
      to = @fs['to']
      @from.copy_to(to).should == to
      @from.copy_to!(to).should == to
    end
  end
    
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
      from, to = @path.dir('from').create, @path.dir('to')
      from.move_to(to).should == to
      from.create
      from.move_to!(to).should == to
    end
  end
end