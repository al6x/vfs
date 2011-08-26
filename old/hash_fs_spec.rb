require 'vfs/drivers/hash_fs'
require 'vfs/drivers/specification'

describe Vfs::Drivers::HashFs do
  it_should_behave_like "vfs driver"

  before do
    @driver = Vfs::Drivers::HashFs.new
  end
end