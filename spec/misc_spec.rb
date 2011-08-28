require 'spec_helper'

describe 'Miscellaneous' do
  with_test_dir

  it "File should respond to :to_file, :to_entry" do
    path = "#{test_dir.path}/file"
    File.open(path, 'w'){|f| f.write 'something'}

    file = nil
    begin
      file = File.open path
      file.to_file.path.should == file.path
      file.to_entry.path.should == file.path
    ensure
      file.close
    end
  end
end