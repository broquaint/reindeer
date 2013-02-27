require 'reindeer/meta'

class Reindeer
  class << self
    # XXX Support a single name for now i.e has %i[a b] won't work yet.
    def has(name, opts={})
      self.class_eval do
        @@meta.add_attribute(name, opts)
      end
    end
  end

  # XXX This needs to happen per calling/composing class. BOO.
  @@meta = Reindeer::Meta.new(self)  
  def meta; @@meta; end

  def initialize(args={})
    for attr in meta.get_attributes
      next unless args.has_key? attr.name
      instance_variable_set "@#{attr.name}", args[attr.name]
    end
  end
end
