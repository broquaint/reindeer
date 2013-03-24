module Reindeer::Role::TypeConstraint
  include Reindeer::Role
  requires :verify

  def check_constraint(v)
    raise Reindeer::TypeConstraint::Invalid, error_message_for(v) unless verify(v)
  end

  def error_message_for(v)
    return "The value '%s' not considered valid by %s" % [v, self.class]
  end
end

class Reindeer
  class TypeConstraint
    class Invalid < StandardError; end
  end
end
