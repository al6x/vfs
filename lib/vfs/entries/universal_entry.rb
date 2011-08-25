module Vfs
  class UniversalEntry < Entry
    #
    # Attributes
    #
    def exist?
      !!get
    end


    #
    # CRUD
    #
    def destroy options = {}
      storage.open do |fs|
        attrs = get
        fs.delete_dir path if attrs and attrs[:dir]
        fs.delete_file path if attrs and attrs[:file]
      end
      self
    end
    alias_method :destroy!, :destroy
  end
end