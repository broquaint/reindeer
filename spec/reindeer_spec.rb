require 'rspec'
include RSpec::Expectations

require 'reindeer'

describe 'Reindeer' do
  it 'should setup a method and initialize an attribute' do
    class FirstOne < Reindeer
      has :abc
    end
    obj = FirstOne.new abc: 'Hello!'
    expect(obj.respond_to? :abc).to be_true
    expect(obj.abc).to eq('Hello!')
  end

  it 'should setup two methods and initialize one attribute' do
    class SecondOne < Reindeer
      has :foo
      has :bar
    end
    obj = SecondOne.new foo: 'World!'
    expect(obj.respond_to? :foo).to be_true
    expect(obj.respond_to? :bar).to be_true
    expect(obj.foo).to eq('World!')
    expect(obj.bar).to be_nil
  end

  it 'should honour is option' do
    class ThirdOne < Reindeer
      has :baz,  is: :ro
      has :quux, is: :rw
      has :xuuq, is: :bare
    end

    obj = ThirdOne.new baz: 'Sawasdee!'
    expect(obj.respond_to? :baz).to be_true
    expect(obj.respond_to? :baz=).to be_false
    expect(obj.respond_to? :quux).to be_true
    expect(obj.respond_to? :quux=).to be_true
    expect(obj.respond_to? :xuuq).to be_false
    expect(obj.meta.has_attribute(:xuuq)).to be_true
    expect(obj.baz).to eq('Sawasdee!')
    expect(obj.quux).to be_nil
    obj.quux = 'super'
    expect(obj.quux).to eq('super')

    expect {
      class FirstFail < Reindeer
        has :epic, is: 'fail'
      end
    }.to raise_error(Reindeer::Meta::Attribute::UnknownIsOption)
  end

  it 'should have a meta per subclass' do
    class FourthOne < Reindeer; end
    class FifthOne  < Reindeer; end
    expect(FourthOne.new.meta == FifthOne.new.meta).to be_false
    expect(FourthOne.new.meta).to eql(FourthOne.meta)
  end
end
