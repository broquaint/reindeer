require 'reindeer/meta/attribute'

class Reindeer
  class Meta

    attr_reader :klass

    def initialize(klass)
      @klass = klass # Hrm, circular? Not a problem with constants?
      # TODO Use a hash
      @attributes = []
    end

    def get_attributes
      @attributes
    end

    def add_attribute(name, opts)
      attr = Reindeer::Meta::Attribute.new(name, opts)
      # XXX Should really do this at this once everything has been
      # defined not up front like this. Don't know of any hooks though :(
      attr.install_methods_in(klass)
      get_attributes << attr
    end

    def setup_attributes(obj, args)
      for attr in get_attributes
        name = attr.name
        if attr.required? and not args.has_key? name
          raise Meta::Attribute::AttributeError,
                "Did not specify required argument '#{name}'"
        end

        obj.instance_eval do
          if args.has_key?(name)
            attr.set_value_for self, args[name]
            #instance_variable_set "@#{name}", args[name]
          elsif attr.has_default? and not attr.is_lazy?
            attr.set_value_for self, attr.get_default_value
            #instance_variable_set "@#{name}", attr.get_default_value
          end
        end
      end
    end
    
    def has_attribute?(name)
      get_attributes.any? {|a| a.name == name }
    end

    def get_attribute(sym)
      sym = sym.sub(/^@/, '').to_sym if sym.is_a?(String)
      get_attributes.select{|a| a.name == sym}.first
    end
  end
end
