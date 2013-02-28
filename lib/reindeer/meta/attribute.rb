class Reindeer
  class Meta
    class Attribute
      # Exceptions!
      class AttributeError < StandardError; end
      
      attr_reader :name

      attr_reader :is_ro, :is_rw, :is_bare

      attr_reader :default_value
      
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

      def get_default_value
        default_value.call
      end
      
      # Predicates
      def required?
        @required
      end
      def has_default?
        not default_value.nil?
      end
      
      private

      def process_opts(opts)
        process_is opts[:is]
        process_default opts[:default] if opts.has_key?(:default)
        @required = opts[:required]
      end

      def process_is(val)
        case val
        when nil then @is_ro = true # Default behaviour if 'is' isn't specified.
        when :ro then @is_ro = true
        when :rw then @is_rw = true
        when :bare then @is_bare = true
        else raise AttributeError, "Unknown value for is '#{val}'"
        end
      end

      def process_default(default)
        @default_value = if default.is_a?(Proc)
                           default
                         else
                           Proc.new { default.clone }
                         end
      end
    end
  end
end
