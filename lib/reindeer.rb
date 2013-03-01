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
    meta.setup_attributes(self, args)
  end
end
