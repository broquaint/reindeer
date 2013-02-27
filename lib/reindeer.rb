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
    for attr in meta.get_attributes
      next unless args.has_key? attr.name
      instance_variable_set "@#{attr.name}", args[attr.name]
    end
  end
end
