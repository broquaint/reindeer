require 'reindeer/meta'

class Reindeer
  class << self
    # XXX Support a single name for now i.e has %i[a b] won't work yet.
    def has(name, opts={})
      meta.add_attribute(name, opts)
    end
    def inherited(subclass)
      meta = Reindeer::Meta.new(subclass)
      meth = Proc.new { meta }
      klass = class << subclass; self; end
      klass.__send__    :define_method, :meta, meth
      subclass.__send__ :define_method, :meta, meth
    end
  end

  def initialize(args={})
    # Move this to RM::Attribute?
    for attr in meta.get_attributes
      name = attr.name
      if attr.required? and not args.has_key? name
        raise Meta::Attribute::AttributeError,
        "Did not specify required argument '#{name}'"
      end
      if args.has_key?(name)
        instance_variable_set "@#{name}", args[name]
      elsif attr.has_default?
        instance_variable_set "@#{name}", attr.get_default_value
      end
    end
  end
end
