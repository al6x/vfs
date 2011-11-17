# It allows dynamically (magically) switching between UniversalEntry/Dir/File.
module Vfs
  class EntryProxy < BasicObject
    attr_reader :_target

    def initialize entry
      raise 'something wrong happening here!' if entry.respond_to?(:proxy?) and entry.proxy?
      self._target = entry
    end

    def proxy?
      true
    end

    protected :==, :equal?, :!, :!=
    protected
      attr_writer :_target

      def respond_to? m
        super or
        ::Vfs::UniversalEntry.method_defined?(m) or
        ::Vfs::Dir.method_defined?(m) or
        ::Vfs::File.method_defined?(m)
      end

      def method_missing m, *a, &b
        unless _target.respond_to? m
          if ::Vfs::UniversalEntry.method_defined? m
            self.target = _target.entry
          elsif ::Vfs::Dir.method_defined? m
            self._target = _target.dir
          elsif ::Vfs::File.method_defined? m
            self._target = _target.file
          end
        end

        _target.send m, *a, &b
      end
  end
end