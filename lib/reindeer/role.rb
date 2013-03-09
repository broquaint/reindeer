class Reindeer
  module Role
    class RoleError < StandardError; end  #ahem

    def Role.included(mod)
      mod.module_eval {
        class << self;
          meta = Reindeer::Meta.new(self)
          define_method :role_meta, Proc.new { meta }
          
          # Make this more composable?
          define_method :has, Proc.new { |name, opts={}|
            role_meta.add_attribute(name, opts)
          }
          
          define_method :requires, Proc.new { |method|
            role_meta.add_required_method(method)
          }

          define_method :assert_requires, Proc.new { |klass|
            not_defined = role_meta.required_methods.select do |meth|
              not klass.instance_methods(false).include?(meth)
            end

            return if not_defined.empty?
            raise RoleError, "The class '#{klass}' composed '#{self}' but didn't define #{not_defined.join ', '}"
          }
        end
      }
    end
    
    private
    def initialise
      super() # Blech
    end
  end
end
