class String
  def to_entry_on storage = nil
    path = self
    storage ||= Vfs.default_storage

    Vfs::Dir.new(storage, '/')[path]
  end
  alias_method :to_entry, :to_entry_on

  def to_file_on storage = nil
    to_entry_on(storage).file
  end
  alias_method :to_file, :to_file_on

  def to_dir_on storage = nil
    to_entry_on(storage).dir
  end
  alias_method :to_dir, :to_dir_on
end