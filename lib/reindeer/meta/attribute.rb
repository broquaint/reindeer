class Reindeer
  class Meta
    class Attribute
      # Exceptions!
      class UnknownIsOption < Exception; end
      
      attr_reader :name

      attr_reader :is_ro, :is_rw, :is_bare
      def initialize(name, opts)
        @name = name
        process_opts opts
        
      end
      def install_accessors_in(klass)
        return if is_bare
        meth = if is_ro
                 :attr_reader
               elsif is_rw
                 :attr_accessor
               end
        name_sym = name.to_sym # Identity!
        klass.class_eval { self.__send__ meth, name_sym }
      end

      private

      def process_opts(opts)
        process_is opts[:is]
      end

      def process_is(val)
        case val
        when nil then @is_ro = true # Default behaviour if 'is' isn't specified.
        when :ro then @is_ro = true
        when :rw then @is_rw = true
        when :bare then @is_bare = true
        else raise UnknownIsOption, "Unknown value for is '#{val}'"
        end
      end
    end
  end
end
