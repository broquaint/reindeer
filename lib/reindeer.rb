require 'reindeer/meta'
require 'reindeer/role'

class Reindeer
  class << self
    # XXX Support a single name for now i.e has %i[a b] won't work yet.
    def has(name, opts={})
      # XXX Should really do this at this once everything has been
      # defined not up front like this. Don't know of any hooks though :(
      meta.add_attribute(name, opts).install_methods_in(self)
    end
    
    def inherited(subclass)
      meta = Reindeer::Meta.new(subclass)
      meth = Proc.new { meta }
      klass = class << subclass; self; end
      klass.__send__    :define_method, :meta, meth
      subclass.__send__ :define_method, :meta, meth
    end
    
    def with(role)
      meta.add_role(role)
    end
  end

  def initialize(args={})
    meta.setup_attributes(self, args)
  end
end
