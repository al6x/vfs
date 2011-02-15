require 'spec_helper'

describe 'Entry' do
  before :each do
    @fs = '/'.to_entry_on(Vfs::Storages::HashFs.new)
    @path = @fs['/a/b/c']
  end
  
  it "name" do
    @path.name.should == 'c'
  end
  
  it 'tmp' do
    tmp = @fs.tmp
    tmp.should be_dir
    
    tmp = nil
    @fs.tmp do |path|
      tmp = path
      tmp.should be_dir
    end
    tmp.should_not exist
  end
  
  it 'should respond to local?'
  
  it 'should respond to host'
  
  describe 'attributes' do
    it 'created_at'
    
    it 'updated_at'
  end
end