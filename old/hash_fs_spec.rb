require 'vfs/storages/hash_fs'
require 'vfs/storages/specification'

describe Vfs::Storages::HashFs do
  it_should_behave_like "vfs storage"

  before do
    @storage = Vfs::Storages::HashFs.new
  end
end