require "spec_helper"

RSpec.describe Savvy do
  it 'can build a namespace' do
    expect(Savvy.namespace('foo', separator: ?:)).to end_with ':foo'
  end

  it 'has a redis configurator' do
    expect do
      Savvy.redis
    end.not_to raise_error

    expect(Savvy.redis.url).to be_a_kind_of String
  end

  it 'has a sidekiq configurator' do
    expect do
      Savvy.sidekiq
    end.not_to raise_error

    expect(Savvy.sidekiq.redis_options).to be_a_kind_of Hash
  end

  it 'has a root' do
    expect(Savvy.root).to eq Savvy.config.root
  end

  it 'can be initialized' do
    allow(Savvy.config).to receive(:setup!)

    expect do
      Savvy.initialize!
    end.not_to raise_error

    expect(Savvy.config).to have_received(:setup!).with(no_args)
  end
end
