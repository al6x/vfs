require 'base'

describe 'Container' do
  before :each do
    @fs = '/'.to_entry_on(Vfs::Storages::HashFs.new)
  end
  
  it "should threat paths as UniversalEntry except it ends with '/'" do
    @fs.should_receive(:entry).with('/a/b')
    @fs['/a/b']
    
    @fs.should_receive(:dir).with('/a/b')
    @fs['/a/b/']
  end
  
  it '/' do
    @fs[:some_path].should == @fs / :some_path
  end
  
  it "UniversalEntry should be wrapped inside of proxy, Dir and File should not" do
    -> {@fs.dir.proxy?}.should raise_error(NoMethodError)
    -> {@fs.file.proxy?}.should raise_error(NoMethodError)
    @fs.entry.proxy?.should be_true
  end
  
  it "sometimes it also should inexplicitly guess that path is a Dir instead of UniversalEntry (but still wrap it inside of Proxy)" do
    dir = @fs['/a/..']
    dir.proxy?.should be_true
    dir.should be_a(Vfs::Dir)
  end
end