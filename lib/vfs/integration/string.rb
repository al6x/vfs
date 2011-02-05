class String
  def to_fs_on storage = nil
    storage ||= Vfs::Storages::Local.new
    Vfs::EntryProxy.new(Vfs::Dir.new(storage, self))
  end
end