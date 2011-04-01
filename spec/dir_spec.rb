require 'spec_helper'

describe 'Dir' do
  before do
    @fs = '/'.to_entry_on(Vfs::Storages::HashFs.new)
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
    
    it 'should destroy recursivelly' do
      dir = @path.dir
      dir.create
      dir.file('file').write 'something'
      dir.dir('dir').create.tap do |dir|
        dir.file('file2').write 'something2'        
      end
      
      dir.destroy
      dir.should_not exist
    end
    
    it 'should be chainable' do
      @path.dir.destroy.should == @path
      @path.dir.destroy!.should == @path
    end
  end
  
  describe 'content' do
    before do
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
    
    it 'should raise error if trying :entries on file' do
      @path.file('some_file').create
      -> {@path.dir('some_file').entries}.should raise_error(/File/)
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
    
    it 'empty?'
  end
  
  describe 'copying' do
    before do 
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
    
    shared_examples_for 'copy_to behavior' do
      it 'should not copy to file (and overwrite if forced)' do
        -> {@from.copy_to @to.file}.should raise_error(/can't copy Dir to File/)
        
        @from.copy_to! @to.file
        @to['file'].read.should == 'something'
      end
      
      it 'should not override files (and override if forced)' do
        @from.copy_to @to
        -> {@from.copy_to @to}.should raise_error(/already exist/)
        
        @from['dir/file2'].write! 'another'
        @from.copy_to! @to
        @to['dir/file2'].read.should == 'another'
      end
    
      it 'should copy to UniversalEntry (and overwrite if forced)' do
        @from.copy_to @to.entry
        -> {@from.copy_to @to.entry}.should raise_error(/already exist/)
        
        @from.copy_to! @to.entry
        @to['file'].read.should == 'something'        
      end
      
      it "shouldn't delete existing content of directory" do
        @to.dir.create!
        @to.file('existing_file').write 'existing_content'
        @to.dir('existing_dir').create
        @to.file('dir/existing_file2').write 'existing_content2'

        @from.copy_to @to
        # copied files
        @to['file'].read.should == 'something'
        @to['dir/file2'].read.should == 'something2'
        # shouldn't delete already existing files
        @to.file('existing_file').read.should == 'existing_content'
        @to.dir('existing_dir').should exist
        @to.file('dir/existing_file2').read.should == 'existing_content2'
      end      
      
      it 'should be chainable' do
        @from.copy_to(@to).should == @to
        @from.copy_to!(@to).should == @to
      end
      
      it "should override without deleting other files" do
        @from.copy_to(@to).should == @to 
        @to.file('other_file').write 'other'
                       
        @from.copy_to!(@to).should == @to
        @to.file('other_file').read.should == 'other'
      end
    end
    
    describe 'general copy' do   
      it_should_behave_like 'copy_to behavior'
      
      before do
        # we using here another HashFs storage, to prevent :effective_dir_copy to be used
        @to = '/'.to_entry_on(Vfs::Storages::HashFs.new)['to']
        
        @from.storage.should_not_receive(:for_spec_helper_effective_copy_used)
      end            
    end    
    
    describe 'effective copy' do
      it_should_behave_like 'copy_to behavior'
      
      before do
        # we using the same HashFs storage, so :effective_dir_copy will be used
        @to = @fs['to']
        
        # @from.storage.should_receive(:for_spec_helper_effective_copy_used).at_least(1).times
      end
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