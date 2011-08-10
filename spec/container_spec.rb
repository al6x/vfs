require 'spec_helper'

describe 'Container' do
  with_test_fs

  it "should threat paths as UniversalEntry except it ends with '/'" do
    test_fs.should_receive(:entry).with('tmp/a/b')
    test_fs['tmp/a/b']

    test_fs.should_receive(:dir).with('tmp/a/b')
    test_fs['tmp/a/b/']
  end

  it '/' do
    test_fs[:some_path].should == test_fs / :some_path
    test_fs[:some_path][:another_path].should == test_fs / :some_path / :another_path
  end

  it "UniversalEntry should be wrapped inside of proxy, Dir and File should not" do
    -> {test_fs.dir.proxy?}.should raise_error(NoMethodError)
    -> {test_fs.file.proxy?}.should raise_error(NoMethodError)
    test_fs.entry.proxy?.should be_true
  end

  it "sometimes it also should inexplicitly guess that path is a Dir instead of UniversalEntry (but still wrap it inside of Proxy)" do
    dir = test_fs['tmp/a/..']
    dir.proxy?.should be_true
    dir.should be_a(Vfs::Dir)
  end
end