class Reindeer
  class Meta
    class Attribute
      attr_reader :name
      def initialize(name, opts)
        @name = name
        @opts = opts
      end
    end
  end
end
