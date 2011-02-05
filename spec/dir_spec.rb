# require 'base'
# 
# describe 'Vfs basic usage' do
#   before :each do
#     @fs = '/'.to_fs_on(Vfs::Storages::HashFs.new)
#     @path = @fs['/some_dir/some_file.txt']
#   end
#   
#   describe 'existence' do
#     it "should check only files" do
#       @path.should_not exist
#       @path.dir.create
#       @path.should be_dir
#       @path.file.create!
#       @path.should be_file
#     end
#   end
#     
#   describe 'read' do
#     it 'should raise error if not exist' do    
#       -> {@path.read}.should raise_error(/not exist/)      
#       -> {@path.read{|buff|}}.should raise_error(/not exist/)      
#     end
#     
#     it 'should not raise error in silent mode' do  
#       @path.read(false).should == ''     
#       data = ""; @path.read(false){|buff| data << buff}; data.should == ''
#     end
#       
#     it "reading" do
#       @path.write('something')
#       
#       @path.read.should == 'something'
#       @path.read(false).should == 'something'      
#       data = ""; @path.read{|buff| data << buff}; data.should == 'something'      
#     end
#   end
#   
#   it 'create' do
#     file = @path.file
#     
#     file.should_receive(:write).with('', false)
#     file.create
#     
#     file.should_receive(:write).with('', true)
#     file.create!
#   end
#   
#   describe 'write' do
#     it 'should create parent dirs if not exists' do
#       @path.parent.should_not exist
#       @path.write 'something'
#       @path.read.should == 'something'
#     end
#     
#     it 'should override existing file if override specified' do
#       @path.write 'something'
#       @path.should be_file
#       -> {@path.write 'another'}.should raise_error(/exist/)
#       @path.write! 'another'
#       @path.read.should == 'another'
#     end
#     
#     it 'should override existing dir if override specified' do
#       @path.dir.create
#       @path.should be_dir
#       -> {@path.write 'another'}.should raise_error(/exist/)
#       @path.write! 'another'
#       @path.read.should == 'another'
#     end
#     
#     it 'writing' do
#       @path.write 'something'
#       @path.read.should == 'something'
#       
#       @path.write! do |writer|
#         writer.call 'another'
#       end
#       @path.read.should == 'another'
#     end
#   end
#   
#   describe 'destroying' do
#     it "file should raise error if it's trying to destroy a dir (unless force specified)" do
#       @path.dir.create
#       -> {@path.file.destroy}.should raise_error(/dir/)
#       @path.file.destroy!
#       @path.entry.should_not exist
#     end
#     
#     it "shouldn't raise if file not exist" do
#       @path.file.destroy
#     end
#   end
# end