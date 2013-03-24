require 'reindeer'

describe 'Reindeer' do
  it 'should have a meta per subclass' do
    class FourthOne < Reindeer; end
    class FifthOne  < Reindeer; end
    expect(FourthOne.new.meta == FifthOne.new.meta).to be_false
    expect(FourthOne.new.meta).to eql(FourthOne.meta)
  end
end
