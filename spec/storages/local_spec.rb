require 'vfs/storages/local'
require 'vfs/storages/specification'

describe Vfs::Storages::Local do
  with_tmp_spec_dir

  before do
    @storage = Vfs::Storages::Local.new spec_dir
    @storage.open
  end

  after do
    @storage.close
  end

  it_should_behave_like 'vfs storage basic'
  it_should_behave_like 'vfs storage attributes basic'
  it_should_behave_like 'vfs storage files'
  it_should_behave_like 'vfs storage full attributes for files'
  it_should_behave_like 'vfs storage dirs'
  it_should_behave_like 'vfs storage full attributes for dirs'
  it_should_behave_like 'vfs storage query'
  it_should_behave_like 'vfs storage tmp dir'
end