require 'reindeer/meta/attribute'

class Reindeer
  class Meta
    def initialize(klass)
      @klass = klass # Hrm, circular? Not a problem with constants?
      @attributes = []
    end
    def get_attributes
      @attributes
    end
    def add_attribute(name, opts)
      get_attributes << Reindeer::Meta::Attribute.new(name, opts)
    end
  end
end
