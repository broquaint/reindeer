require 'reindeer'

describe 'Reindeer types' do
  it 'should constrain attributes' do
    class QuietWord < Reindeer
      with Reindeer::Role::TypeConstraint

      def verify(val)
        val =~ /^[a-z]+$/
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
end
