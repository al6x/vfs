module Vfs
  module Marks
    def mark key
      ensure_mark_requrements!
      bash "touch #{marks_dir}/#{key}"
    end

    def has_mark? key
      ensure_mark_requrements!
      file_exist? "#{marks_dir}/#{key}"
    end
    
    def clear_marks
      bash "rm -r #{marks_dir}"
    end
    
    protected
      def marks_dir
        home "/.marks"
      end

      def ensure_mark_requrements!
        unless @ensure_mark_requrements
          create_directory marks_dir unless directory_exist? marks_dir
          @ensure_mark_requrements = true
        end
      end
  end
end