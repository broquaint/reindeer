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
    expect(obj.meta.has_attribute?(:xuuq)).to be_true
    expect(obj.baz).to eq('Sawasdee!')
    expect(obj.quux).to be_nil
    obj.quux = 'super'
    expect(obj.quux).to eq('super')

    expect {
      class FirstFail < Reindeer
        has :epic, is: 'fail'
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

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

  it 'should have default attribute values' do
    class SeventhOne < Reindeer
      # clone, clone, execute
      has :ichi, default: 'one'
      has :ni,   default: %w[two three]
      has :san,  default: -> { [:four, :five] }
    end

    expect(SeventhOne.new.ichi).to eq('one')

    a = SeventhOne.new.ni
    expect(a).to eq(%w{two three})
    a << 'four five'
    expect(SeventhOne.new.ni).to eq(%w{two three})

    b = SeventhOne.new.san
    expect(b).to eq([:four, :five])
    b << :six
    expect(SeventhOne.new.san).to eq([:four, :five])
  end

  it 'should have lazily built attribute values' do
    class EighthOne < Reindeer
      private
      def build_ha
        'mmm, lazy'
      end
      public
      has :ha,  lazy: true, builder: :build_ha
      has :hok, lazy: true, default: -> { 'not eager' }
    end

    expect(EighthOne.new.ha).to eq('mmm, lazy')
    expect(EighthOne.new.hok).to eq('not eager')

    obj = EighthOne.new

    expect(obj.has_ha).to  be_false
    expect(obj.has_hok).to be_false

    expect(obj.ha).to  eq('mmm, lazy')
    expect(obj.hok).to eq('not eager')

    expect(obj.has_ha).to  be_true
    expect(obj.has_hok).to be_true

    obj.clear_ha
    obj.clear_hok

    expect(obj.has_ha).to  be_false
    expect(obj.has_hok).to be_false
  end
end
