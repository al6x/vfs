require 'vfs/drivers/local'
require 'vfs/drivers/specification'

describe Vfs::Drivers::Local do
  with_test_dir

  before do
    @driver = Vfs::Drivers::Local.new root: test_dir.to_s
    @driver.open
  end

  after do
    @driver.close
  end

  it_should_behave_like 'vfs driver basic'
  it_should_behave_like 'vfs driver attributes basic'
  it_should_behave_like 'vfs driver files'
  it_should_behave_like 'vfs driver full attributes for files'
  it_should_behave_like 'vfs driver dirs'
  it_should_behave_like 'vfs driver full attributes for dirs'
  it_should_behave_like 'vfs driver query'
  it_should_behave_like 'vfs driver tmp dir'
end