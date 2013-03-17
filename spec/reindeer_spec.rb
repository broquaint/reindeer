require 'rspec'
include RSpec::Expectations

require 'reindeer'

describe 'Reindeer' do
  it 'should have a meta per subclass' do
    class FourthOne < Reindeer; end
    class FifthOne  < Reindeer; end
    expect(FourthOne.new.meta == FifthOne.new.meta).to be_false
    expect(FourthOne.new.meta).to eql(FourthOne.meta)
  end

  it 'should have required attributes' do
    class SixthOne < Reindeer
      has :foo, required: true
    end
    expect(SixthOne.new(foo: 'yep').foo).to eq('yep')
    expect {
      SixthOne.new
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should compose a role' do
    module FirstRole
      include Reindeer::Role
      has :trois, default: 'cool'
      requires :quatre
      def cinq
        %w{cool beans}
      end
    end
    class ThirteenthOne < Reindeer
      with FirstRole
      def quatre
        'beans'
      end
      meta.compose!
    end

    obj = ThirteenthOne.new
    expect(obj.trois).to eq('cool')
    expect(obj.quatre).to eq('beans')
    expect(obj.cinq).to eq(%w{cool beans})

    expect {
      module BankRole
        include Reindeer::Role
        requires :money
      end
      class SeventhFail < Reindeer
        with BankRole
        meta.compose!
      end
    }.to raise_error(Reindeer::Role::RoleError)
  end

  it 'should compose multiple roles' do
    module SecondRole
      include Reindeer::Role
      has :foo
      def bar; 'two'; end
    end
    module ThirdRole
      include Reindeer::Role
      has :baz
      def quux; 'four'; end
    end
    class FourteenthOne < Reindeer
      with SecondRole
      with ThirdRole
      meta.compose!
    end
    
    obj = FourteenthOne.new(foo: 'one', baz: 'three')
    expect(obj.foo).to eq('one')
    expect(obj.bar).to eq('two')
    expect(obj.baz).to eq('three')
    expect(obj.quux).to eq('four')
  end
end
