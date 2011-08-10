module Vfs
  class Path < String
    def initialize path = '/', options = {}
      if options[:skip_normalization]
        super path
        @probably_dir = options[:probably_dir]
      else
        Path.validate! path
        path, probably_dir = Path.normalize_to_string path
        raise "invalid path '#{path}' (you are outside of the root)!" unless path
        super path
        @probably_dir = probably_dir
      end
    end

    def + path = ''
      path = path.to_s
      Path.validate! path, false

      if Path.absolute?(path)
        Path.normalize path
      elsif path.empty?
        self
      else
        Path.normalize "#{self}#{'/' unless self == '/'}#{path}"
      end
    end

    def parent
      self + '..'
    end

    def probably_dir?
      !!@probably_dir
    end

    def name
      unless @name
        root = self[0..0]
        @name ||= split('/').last || root
      end
      @name
    end

    class << self
      def absolute? path
        path =~ /^[\/~\/]|^\.$|^\.\//
      end

      def valid? path, forbid_relative = true, &block
        result, err = if forbid_relative and !absolute?(path)
          [false, "path must be started with '/', or '.'"]
        elsif path =~ /.+\/~$|.+\/$|\/\.$/
          [false, "path can't be ended with '/', '/~', or '/.'"]
        elsif path =~ /\/\/|\/~\/|\/\.\//
          [false, "path can't include '/./', '/~/', '//' combinations!"]
        # elsif path =~ /.+[~]|\/\.\//
        #   [false, "'~', or '.' can be present only at the begining of string"]
        else
          [true, nil]
        end

        block.call err if block and !result and err
        result
      end

      def normalize path
        path, probably_dir = normalize_to_string path
        unless path
          nil
        else
          Path.new(path, skip_normalization: true, probably_dir: probably_dir)
        end
      end

      def validate! path, forbid_relative = true
        valid?(path, forbid_relative){|error| raise "invalid path '#{path}' (#{error})!"}
      end

      def normalize_to_string path
        root = path[0..0]
        result, probably_dir = [], false

        parts = path.split('/')[1..-1]
        if parts
          parts.each do |part|
            if part == '..' and root != '.'
              return nil, false unless result.size > 0
              result.pop
              probably_dir ||= true
            # elsif part == '.'
            #   # do nothing
            else
              result << part
              probably_dir &&= false
            end
          end
        end
        normalized_path = result.join('/')

        probably_dir ||= true if normalized_path.empty?

        return "#{root}#{'/' unless root == '/' or normalized_path.empty?}#{normalized_path}", probably_dir
      end
    end

    # protected
    #   def delete_dir_mark
    #     path = path.to_s.sub(%r{/$}, '')
    #   end
    #
    #
    #   def root_path? path
    #     path =~ /^[#{ROOT_SYMBOLS}]$/
    #   end
    #
    #   def split_path path
    #     path.split(/#{ROOT_SYMBOLS}/)
    #   end
    #
    #   def dir_mark? path
    #     path =~ %r{/$}
    #   end
  end
end