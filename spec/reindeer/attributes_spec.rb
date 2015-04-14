require 'reindeer'

describe 'Reindeer attributes' do
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

    expect {
      class SecondFail < Reindeer
        has :blam, lazy: true, builder: :flub, default: 'blub'
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
    expect {
      class ThirdFail < Reindeer
        has :blam, lazy: true
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should support the lazy_build shorthand' do
    class NinthOne < Reindeer
      has :jet, lazy_build: true
      private
      def build_jet
        :symbolic
      end
    end

    expect(NinthOne.new.jet).to eq(:symbolic)

    obj = NinthOne.new

    expect(obj.has_jet?).to be_false
    expect(obj.jet).to eq(:symbolic)
    expect(obj.has_jet?).to be_true
    obj.clear_jet!
    expect(obj.has_jet?).to be_false

    expect {
      class FourthFail < Reindeer
        has :nope, lazy_build: true, default: -> { 'boom!' }
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should support delegation with handles' do
    class TenthOne < Reindeer
      has :bat, is: :bare, handles: [:sub]
    end

    obj = TenthOne.new(bat: 'zoo')
    expect(obj.sub /z/, 'f').to eq('foo')
    expect(obj.respond_to?(:bat)).to be_false

    expect {
      class FifthFail < Reindeer
        has :bleh, handles: Object.new
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should have simple type constraints' do
    class EleventhOne < Reindeer
      has :gau, is_a: String
      has :sip, is_a: Fixnum
    end

    obj = EleventhOne.new(gau: 'foo', sip: 123)
    expect(obj.gau).to eq('foo')
    expect(obj.sip).to eq(123)

    expect {
      EleventhOne.new(gau: [])
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
    expect {
      EleventhOne.new(sip: {})
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should should consistently apply type constraints' do
    class TwelvethOne < Reindeer
      has :une,  is_a: Array, lazy_build: true
      has :deux, is_a: Hash,  is: :rw
      private
      def build_une
        %w{cool beans}
      end
    end

    obj = TwelvethOne.new
    expect(obj.une).to eq(%w{cool beans})
    obj.deux = { hashie: 'hash' }
    expect(obj.deux).to eq({ hashie: 'hash' })

    expect {
      TwelvethOne.new.deux = []
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)

    expect {
      class SixthFail < Reindeer
        has :saywaht, is_a: Regexp, lazy: true, default: 'this here'
      end
      SixthFail.new.saywaht
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should compose attributes up the inheritance chain' do
    class SeventeenthOne < Reindeer
      has :foo
    end
    module FourthRole
      include Reindeer::Role
      has :bar
    end
    class EighteenthOne < SeventeenthOne
      with FourthRole
      has :baz
      meta.compose!
    end

    obj = EighteenthOne.new(foo: 1, bar: 2, baz: 3)
    expect(obj.foo).to eq(1)
    expect(obj.bar).to eq(2)
    expect(obj.baz).to eq(3)
  end

  it 'should raise an exception for lazy required attributes' do
    expect {
      class LazyRequiredFail < Reindeer
        has :zoiks, lazy: true, required: true
      end
    }.to raise_error(Reindeer::Meta::Attribute::AttributeError)
  end

  it 'should find attributes up the inheritance chain' do
    class NineteenthOne < Reindeer
      has :foo, is: :rw
      class Specialised < NineteenthOne
        has :bar
      end
    end

    obj = NineteenthOne::Specialised.new(bar: 'abc')
    obj.foo = 123
    expect(obj.foo).to eq(123)
  end
end
