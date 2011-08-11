module Vfs
  class UniversalEntry < Entry
    #
    # Attributes
    #
    def exist?
      attrs = get
      !!(attrs[:dir] or attrs[:file])
    end


    #
    # CRUD
    #
    def destroy options = {}
      storage.open_fs do |fs|
        attrs = get
        fs.delete_dir path if attrs[:dir]
        fs.delete_file path if attrs[:file]
      end
      self
    end
    alias_method :destroy!, :destroy
  end
end