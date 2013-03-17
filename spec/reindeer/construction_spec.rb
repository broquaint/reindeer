require 'rspec'
include RSpec::Expectations

require 'reindeer'

describe 'Reindeer construction' do
  it 'should call all build methods' do
    class FifteenthOne < Reindeer
      def build(args)
        things << :super
      end
    end
    class SixteenthOne < FifteenthOne
      has :things, default: []
      def build(args)
        things << :neat
      end
    end

    obj = SixteenthOne.new
    expect(obj.things).to eq([:super, :neat])
  end
end
