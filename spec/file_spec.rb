require 'spec_helper'

describe 'File' do
  before do
    @fs = '/'.to_entry_on(Vfs::Storages::HashFs.new)
    @path = @fs['/a/b/c']
  end
  
  describe 'existence' do
    it "should check only files" do
      @path.should_not exist
      @path.dir.create
      @path.should be_dir
      @path.file.should_not exist
      @path.file.create!
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
    
    it 'content' do
      @path.write('something')
      @path.content.should == 'something'
    end
  end
  
  describe 'creation' do
    it 'create' do
      file = @path.file
    
      file.should_receive(:write).with('', {})
      file.create
    
      file.should_receive(:write).with('', override: true)
      file.create!
    end
    
    it 'should be chainable' do
      @path.file.create.should == @path
      @path.file.create!.should == @path
    end
  end
  
  describe 'write' do
    it 'should create parent dirs if not exists' do
      @path.parent.should_not exist
      @path.write 'something'
      @path.read.should == 'something'
    end
    
    it 'should override existing file if override specified' do
      @path.write 'something'
      @path.should be_file
      -> {@path.write 'another'}.should raise_error(Vfs::Error, /exist/)
      @path.write! 'another'
      @path.read.should == 'another'
    end
    
    it 'should override existing dir if override specified' do
      @path.dir.create
      @path.should be_dir
      -> {@path.write 'another'}.should raise_error(Vfs::Error, /exist/)
      @path.write! 'another'
      @path.read.should == 'another'
    end
    
    it 'writing' do
      @path.write 'something'
      @path.read.should == 'something'

      @path.write! do |writer|
        writer.call 'another'
      end
      @path.read.should == 'another'
    end
    
    it 'append' do
      file = @path.file
      file.should_receive(:write).with('something', append: true)
      file.append 'something'
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
      
      @from.write! 'another'
      -> {@from.copy_to to}.should raise_error(Vfs::Error, /exist/)
      target = @from.copy_to! to
      target.read.should == 'another'
      target.should == to
    end
    
    it 'should copy to file (and overwrite if forced)' do
      check_copy_for @fs.file('to')
    end
    
    it 'should copy to dir (and overwrite if forced)' do
      check_copy_for @fs.dir("to")
    end
    
    it 'should copy to UniversalEntry (and overwrite if forced)' do
      check_copy_for @fs.entry('to')
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
      from, to = @path.file('from').create, @path.file('to')
      from.move_to(to).should == to
      from.create
      from.move_to!(to).should == to
    end
  end
  
  describe 'destroying' do
    it "should raise error if it's trying to destroy a dir (unless force specified)" do
      @path.dir.create
      -> {@path.file.destroy}.should raise_error(Vfs::Error, /can't destroy Dir/)
      @path.file.destroy!
      @path.entry.should_not exist
    end
    
    it "shouldn't raise if file not exist" do
      @path.file.destroy
    end
    
    it 'should be chainable' do
      @path.file.destroy.should == @path
      @path.file.destroy!.should == @path
    end
  end
  
  describe "extra stuff" do
    it 'render' do
      template = @fs / 'letter.erb'
      template.write "Hello dear <%= name %>"
      template.render(name: 'Mary').should == "Hello dear Mary"
    end
    
    begin
      require 'haml'
      
      it 'render using other template engines' do      
        template = @fs / 'letter.haml'
        template.write "Hello dear \#{name}"
        template.render(name: 'Mary').should =~ /Hello dear Mary/
      end
    rescue LoadError
      warn "no :haml template engine, skipping rendering with haml specs"
    end
    
    it 'size'
  end
end