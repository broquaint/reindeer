require 'reindeer/meta/attribute'

class Reindeer
  class Meta

    attr_reader :klass

    def initialize(klass)
      @klass = klass # Hrm, circular? Not a problem with constants?
      @attributes = []
    end

    def get_attributes
      @attributes
    end

    def add_attribute(name, opts)
      attr = Reindeer::Meta::Attribute.new(name, opts)
      # XXX Should really do this at this once everything has been
      # defined not up front like this. Don't know of any hooks though :(
      attr.install_accessors_in(klass)
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
            instance_variable_set "@#{name}", args[name]
          elsif attr.has_default?
            instance_variable_set "@#{name}", attr.get_default_value
          end
        end
      end
    end
    
    def has_attribute?(name)
      get_attributes.any? {|a| a.name == name }
    end
  end
end
