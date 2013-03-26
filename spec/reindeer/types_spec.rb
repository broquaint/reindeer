require 'reindeer'

describe 'Reindeer types' do
  it 'should constrain attributes' do
    class QuietWord < Reindeer
      with Reindeer::Role::TypeConstraint

      def verify(val)
        val.downcase == val
      end

      meta.compose!
    end

    class SoftlySpoken < Reindeer
      has :start, is_a: String, type_of: QuietWord
    end

    obj = SoftlySpoken.new(start: 'foo')
    expect(obj.start).to eq('foo')

    expect {
      obj = SoftlySpoken.new(start: 'LOUD NOISES')
    }.to raise_error(Reindeer::TypeConstraint::Invalid)
  end

  it 'should have useful a error message' do
    class LoudWord < Reindeer
      with Reindeer::Role::TypeConstraint

      def verify(val)
        val.upcase == val
      end

      def error_message_for(val)
        "THE VALUE '#{val}' WASN'T LOUD ENOUGH"
      end

      meta.compose!
    end

    class SergeantMajor < Reindeer
      has :order, is_a: String, type_of: LoudWord
    end

    obj = SergeantMajor.new(order: 'TEN HUT')
    expect(obj.order).to eq('TEN HUT')

    expect {
      SergeantMajor.new(order: 'quiet please')
    }.to raise_error(Reindeer::TypeConstraint::Invalid, /WASN'T LOUD ENOUGH/)
  end
end
