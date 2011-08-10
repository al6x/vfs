require 'vfs/storages/local'
require 'vfs/storages/specification'

describe Vfs::Storages::Local do
  it_should_behave_like "vfs storage"

  before do
    @storage = Vfs::Storages::Local.new
  end

  describe 'attributes' do
    it 'created_at'

    it 'updated_at'
  end
end