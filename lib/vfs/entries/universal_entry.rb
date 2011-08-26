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
    def destroy
      destroy_entry
    end
  end
end