module Vfs
  class Entry
    module SpecialAttributes
      def created_at
        safe_get :created_at
      end

      def updated_at
        safe_get :updated_at
      end

      protected
        def safe_get name
          if value = get[name]
            value
          else
            if get[:dir] or get[:file]
              raise "attribute :#{name} not supported for #{storage.class}!"
            else
              raise "entry #{path} not exist!"
            end
          end
        end
    end
  end
end