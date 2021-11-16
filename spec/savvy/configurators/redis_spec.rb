RSpec.describe Savvy::Configurators::Redis do
  let(:host)  { '127.0.0.1' }
  let(:port)  { 6379 }
  let(:db)    { 1 }

  let(:redis_env_url) { "redis://#{host}:#{port}/#{db}" }

  let(:fake_env) do
    {
      'REDIS_URL' => redis_env_url
    }
  end

  let(:savvy_env) { Savvy::EnvironmentReader.new fake_env }

  let(:savvy_config) do
    Savvy::Configuration.new root: TEST_ROOT, env: savvy_env
  end

  let(:instance) { described_class.new config: savvy_config }

  subject { instance }

  it { is_expected.to be_valid }

  it 'gets the expected url' do
    expect(instance.url).to eq redis_env_url
  end

  it 'has all the expected parameters' do
    expect(instance).to have_attributes host: host, port: port, db: db
  end

  it 'can generate a hash' do
    expect(instance.to_h).to eq({
      host: host,
      port: port,
      password: nil,
      db: db,
      scheme: "redis",
      ssl: false,
      namespace: instance.namespace
    })
  end

  specify do
    expect(instance).not_to have_ssl
  end

  context 'with an invalid URL' do
    let(:redis_env_url) { 'redis://something busted' }

    it { is_expected.not_to be_valid }

    def self.raises_error!(method_name)
      specify "calling #{method_name} raises an error" do
        expect do
          instance.__send__(method_name)
        end.to raise_error Savvy::RedisError
      end
    end

    raises_error! :db
    raises_error! :host
    raises_error! :namespace
    raises_error! :namespaced_url
    raises_error! :password
    raises_error! :port
    raises_error! :scheme
    raises_error! :url
  end

  context 'when no db is specified in the url' do
    let(:redis_env_url) { "redis://#{host}:#{port}" }

    it 'has the default database' do
      expect(instance.db).to eq 0
    end
  end

  context "with a password-protected rediss:// url" do
    let(:username) { "redis" }
    let(:password) { "123456" }
    let(:userinfo) { "#{username}:#{password}" }
    let(:port) { "6380" }
    let(:redis_env_url) { "rediss://#{userinfo}@#{host}:#{port}" }

    specify do
      expect(instance).to have_ssl
    end

    it "has the proper scheme" do
      expect(instance.scheme).to eq "rediss"
    end

    it "builds a URL with the right scheme" do
      expect(instance.url).to start_with "rediss://"
    end

    it "includes the userinfo in the URL" do
      expect(instance.url).to include password
    end
  end
end
