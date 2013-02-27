require 'rspec'
include RSpec::Expectations

require 'reindeer'

describe 'Reindeer' do
  it 'should work' do
    class FirstOne < Reindeer
      has :abc
    end
    obj = FirstOne.new abc: 'Hello!'
    expect(obj.respond_to? :abc).to be_true
    expect(obj.abc).to eq('Hello!')
  end
end
