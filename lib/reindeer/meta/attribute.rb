class Reindeer
  class Meta
    class Attribute
      # Exceptions!
      class AttributeError < StandardError; end

      attr_reader :name

      attr_reader :is_ro, :is_rw, :is_bare

      attr_reader :default_value
      attr_reader :lazy_builder, :lazy_build

      attr_reader :handles

      def initialize(name, opts)
        @name = name
        process_opts opts
      end

      def to_var
        "@#{name.to_s}"
      end

      def install_methods_in(klass)
        install_accessors_in klass
        if lazy_build
          install_clearer_in   klass
          install_predicate_in klass
        end
        install_delegators klass if has_handles?
      end

      def install_accessors_in(klass)
        return if is_bare

        if is_lazy?
          attr_name = to_var
          builder   = lazy_builder
          # TODO Have the attr_* replace the builder once attribute value is set.
          klass.__send__ :define_method, name, Proc.new {
            if instance_variable_defined? attr_name
              instance_variable_get attr_name
            else
              instance_variable_set attr_name,
                builder.is_a?(Symbol) ? __send__(builder) : builder.call()
            end
          }
        else
          meth = if is_ro
                   :attr_reader
                 elsif is_rw
                   :attr_accessor
                 end
          name_sym = name.to_sym # Identity!
          klass.class_eval { self.__send__ meth, name_sym }
        end
      end

      def install_clearer_in(klass)
        attr_name = to_var
        klass.__send__ :define_method, "clear_#{name}", Proc.new {
          remove_instance_variable attr_name
        }
      end
      
      def install_predicate_in(klass)
        attr_name = to_var
        klass.__send__ :define_method, "has_#{name}", Proc.new {
          instance_variable_defined? attr_name
        }
      end

      def install_delegators(klass)
        attr_name = to_var
        handles.each do |method|
          klass.__send__ :define_method, method, Proc.new {|*args|
            instance_variable_get(attr_name).__send__(method, *args)
          }
        end
      end

      def get_default_value
        default_value.call
      end

      # Predicates
      def required?
        @required
      end
      # There must be a cleaner way to get a boolean.
      def has_default?
        not default_value.nil?
      end
      def is_lazy?
        not @lazy_builder.nil?
      end
      def has_handles?
        not handles.nil?
      end

      private

      def process_opts(opts)
        process_is opts[:is]
        process_default opts[:default] if opts.has_key?(:default)
        @required = opts[:required]
        process_lazy opts[:lazy], opts if opts.has_key?(:lazy)

        if opts[:lazy_build]
          raise AttributeError, "Can't have lazy_build and default, pick one!" if has_default?
          @lazy_builder = "build_#{name}".to_sym
          @lazy_build   = true
        end

        process_handles opts[:handles] if opts.has_key?(:handles)
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

      # TODO check default is callable.
      def process_default(default)
        @default_value = if default.is_a?(Proc)
                           default
                         else
                           Proc.new { default.clone }
                         end
      end

      def process_lazy(is_lazy, opts)
        if opts[:builder] and opts[:default]
          raise AttributeError, "Can't use lazy & builder for lazy"
        elsif not opts[:builder] and not opts[:default]
          raise AttributeError, "Must specify lazy or builder for lazy"
        end

        @lazy_builder = opts[:builder] || opts[:default]
      end

      def process_handles(handles)
        raise AttributeError, "Only support an Array of methods is supported for handles" unless handles.is_a?(Array)
        @handles = handles
      end
    end
  end
end
