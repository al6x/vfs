require 'base'

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
end