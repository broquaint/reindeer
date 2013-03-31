require 'reindeer'

describe 'Reindeer roles' do
  it 'should compose a role' do
    # TODO more tests smaller roles (to begin with)
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

  it 'should know if an object does a role' do
    module DoesRole
      include Reindeer::Role
    end
    class ThatDoesARole < Reindeer
      with DoesRole
      meta.compose!
    end
    class ThatDoesNoRole < Reindeer; end

    expect(ThatDoesARole.does? DoesRole).to be_true
    expect(ThatDoesARole.new.does? DoesRole).to be_true

    expect(ThatDoesNoRole.does? DoesRole).to be_false
    expect(ThatDoesNoRole.new.does? DoesRole).to be_false
  end
end
