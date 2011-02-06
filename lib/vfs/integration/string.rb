class String
  def to_fs_on storage = nil
    path = self
    storage ||= Vfs::Storages::Local.new    
    
    Vfs::Dir.new(storage, '/')[path]
  end
  alias_method :to_fs, :to_fs_on
end