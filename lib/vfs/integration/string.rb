class String
  def to_fs_on storage = nil
    path = self
    storage ||= Vfs::Storages::Local.new    
    Vfs::Dir.new(storage, '/')[path]
  end
end