require 'base'

describe 'Entry' do
  before :each do
    @fs = '/'.to_fs_on(Vfs::Storages::HashFs.new)
    @path = @fs['/a/b/c']
  end
  
  it "name" do
    @path.name.should == 'c'
  end
  
  
end