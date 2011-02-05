require 'base'

describe "Path" do
  before(:all){Path = Vfs::Path}
  after(:all){remove_constants :Path}
  
  it 'validations' do
    %w(
      /
      /a 
      /a/b/c 
      /a/../c      
      /a/...
      /a/./c
      ~/a      
    ).each{|path| Path.should be_valid(path)}    
    
    special = ['']
    (%w(      
      /a/~/c 
      /a/
      ~/
    ) + special).each{|path| Path.should_not be_valid(path)}
  end
  
  it 'normalize' do
    special = ['/a/../..', nil]
    (%w(
      /a        /a
      ~/a       ~/a
      /a/./b    /a/b
      /a/../c   /c
      /         /
      ~         ~
    ) + special).each_slice(2) do |path, normalized_path| 
      Path.normalize(path).should == normalized_path
    end
  end
  
  it "+" do
    special = [
      '/a', '../..', nil,
      '/',  '..',    nil,     
    ]
    (%w(
      /         /a        /a
      /         ~/a       ~/a
      /a        b/c       /a/b/c
      /a/b/c    .././d    /a/b/d
    ) + special).each_slice(3) do |base, path, sum| 
      (Path.new(base) + path).should == sum
    end
  end
  
  it 'parent' do
    special = ['/', nil]
    (%w(
      /a/b/c    /a/b   
    ) + special).each_slice(2) do |path, parent|
      Path.new(path).parent.should == parent
    end
  end
  
  it "should raise error if current dir outside of root" do
    -> {Path.new('/a/../..')}.should raise_error(/outside.*root/)
  end
  
  it "should guess if current dir is a dir" do    
    [
      '/a',      false,
      '/',       true,
      '~',       true,
      '/a/..',   true,
      '/a/../b', false,
    ].each_slice 2 do |path, result|
      Path.new(path).probably_dir?.should == result
    end
    
    path = Path.new('/a/b/c')    
    [
      path,           false,
      (path + '..'),  true,
      path.parent,    true,
      
      (path + '/'),   true,
      (path + '/a'),  false,      
    ].each_slice 2 do |path, result|
      path.probably_dir?.should == result
    end
  end
  
  it 'to_s' do
    Path.new.to_s.class.should == String
  end  
end