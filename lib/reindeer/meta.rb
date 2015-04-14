require 'reindeer/meta/attribute'

class Reindeer
  class Meta

    attr_reader :klass
    attr_reader :required_methods

    def initialize(klass)
      @klass = klass # Hrm, circular? Not a problem with constants?
      # TODO Use a hash
      @attributes = []
      @roles      = []
      @required_methods = []
    end

    def build_all(obj, args)
      to_build = obj.class.ancestors.take_while { |klass|
        klass != Reindeer
      }.reverse

      (to_build - obj.class.included_modules).each { |klass|
        # TODO assume build is private.
        build = klass.instance_method(:build)
        build.bind(obj).call(args)
      }
    end

    def compose!
      all_roles.each do |role|
        role.assert_requires klass
        # role.compose_methods! klass
        klass.__send__ :include, role # Blech
        role.role_meta.get_attributes.each do |attr|
          attr.install_methods_in klass
        end

        get_attributes.push(*role.role_meta.get_attributes)
      end
    end

    def add_role(role)
      @roles << role
    end

    def all_roles
      @roles
    end

    # Not sure if this is the best place for it.
    def add_required_method(method)
      @required_methods << method
    end

    def get_attributes
      @attributes
    end

    def get_all_attributes
      all_classes = klass.ancestors.take_while{|k| k!=Reindeer}.select{|c|
        c.class == Class
      }.reverse
      all_classes.collect{|c| c.meta.get_attributes}.flatten
    end

    def add_attribute(name, opts)
      attr = Reindeer::Meta::Attribute.new(name, opts)
      get_attributes << attr
      return attr
    end

    def setup_attributes(obj, args)
      for attr in get_all_attributes
        name = attr.name
        if attr.required? and not args.has_key? name
          raise Meta::Attribute::AttributeError,
                "Did not specify required argument '#{name}'"
        end

        obj.instance_eval do
          if args.has_key?(name)
            attr.set_value_for self, args[name]
          elsif attr.has_default? and not attr.is_lazy?
            attr.set_value_for self, attr.get_default_value
          end
        end
      end
    end
    
    def has_attribute?(name)
      get_all_attributes.any? {|a| a.name == name }
    end

    def get_attribute(sym)
      sym = sym.sub(/^@/, '').to_sym if sym.is_a?(String)
      get_all_attributes.select{|a| a.name == sym}.first
    end
  end
end
