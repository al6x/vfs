# describe "file operations" do    
#   it "file_exist?" do
#     @driver.file_exist?(@remote_file).should be_false
#     @driver.upload_file(@local_file, @remote_file)
#     @driver.file_exist?(@remote_file).should be_true
#   end
# 
#   it "upload_file" do
#     @driver.upload_file(@local_file, @remote_file)
#     @driver.file_exist?(@remote_file).should be_true
# 
#     lambda{@driver.upload_file(@local_file, @remote_file)}.should raise_error(/exists/)
# 
#     # upload with override
#     @driver.upload_file(@local_file, @remote_file, true)
#     @driver.file_exist?(@remote_file).should be_true
#   end
# 
#   it "download_file" do
#     lambda{@driver.download_file(@remote_file, @check_file)}.should raise_error(/not exists/)
#     @driver.upload_file(@local_file, @remote_file)
#     @driver.download_file(@remote_file, @check_file)
#     File.read(@local_file).should == File.read(@check_file)
#   end          
# 
#   it "remove_file" do
#     lambda{@driver.remove_file(@remote_file)}.should raise_error(/not exists/)
#     @driver.upload_file(@local_file, @remote_file)
#     @driver.file_exist?(@remote_file).should be_true
#     @driver.remove_file(@remote_file)
#     @driver.file_exist?(@remote_file).should be_false
#   end    
# end