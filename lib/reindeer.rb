class Reindeer
  class << self
    # XXX Support a single name for now i.e has %i[a b] won't work yet.
    def has(name, opts={})
      self.class_eval do
        @@attributes ||= []  # This isn't nice but will do for now.
        @@attributes << name
        attr_reader name
      end
    end
  end
  def initialize(args={})
    # XXX Should be poking at Meta::Attribute things.
    for attr in @@attributes.select{|a| args.has_key? a}
      instance_variable_set "@#{attr.to_s}", args[attr]
    end
  end
end
