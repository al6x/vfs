require 'spec_helper'

describe 'Entry' do
  with_test_dir

  before do
    @path = test_dir['a/b/c']
  end

  it "name" do
    @path.name.should == 'c'
  end

  it "string integration" do
    '/'.to_entry.path.should == '/'
    'a'.to_entry.path.should == "./a"
  end

  it 'tmp' do
    tmp = test_dir.tmp
    tmp.should be_dir
    tmp.destroy

    tmp = nil
    test_dir.tmp do |path|
      tmp = path
      tmp.should be_dir
    end
    tmp.should_not exist
  end

  it 'should respond to local?' do
    test_dir.should respond_to(:local?)
  end

  it 'created_at, updated_at, size' do
    file = test_dir.file('file').write 'data'
    file.created_at.class.should == Time
    file.updated_at.class.should == Time
    file.size.should == 4
  end
end