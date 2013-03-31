require 'reindeer/meta'
require 'reindeer/role'
require 'reindeer/role/typeconstraint'

class Reindeer
  class << self
    # XXX Support a single name for now i.e has %i[a b] won't work yet.
    def has(name, opts={})
      # XXX Should really do this at this once everything has been
      # defined not up front like this. Don't know of any hooks though :(
      meta.add_attribute(name, opts).install_methods_in(self)
    end
    
    def with(role)
      meta.add_role(role)
    end

    def does?(role)
      meta.all_roles.include? role
    end

    def inherited(subclass)
      provide_meta subclass
    end

    def provide_meta(subclass)
      meta = Reindeer::Meta.new(subclass)
      meth = Proc.new { meta }
      klass = class << subclass; self; end
      klass.__send__    :define_method, :meta, meth
      subclass.__send__ :define_method, :meta, meth
    end
  end

  def initialize(args={})
    meta.setup_attributes(self, args)
    meta.build_all(self, args)
  end

  def build(args); end

  def does?(role)
    meta.all_roles.include? role
  end
end
