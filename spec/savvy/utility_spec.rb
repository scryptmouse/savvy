RSpec.describe Savvy::Utility do
  describe '#valid_env_var?' do
    it 'is true with a present string' do
      expect(described_class.valid_env_var?('FOO')).to be_truthy
    end

    it 'is false with invalid values' do
      expect(described_class.valid_env_var?('')).to be_falsey
      expect(described_class.valid_env_var?([])).to be_falsey
    end
  end

  describe '#valid_env_vars?' do
    it 'works with an array of strings' do
      expect(described_class.valid_env_vars?(%w[FOO BAR BAZ])).to be_truthy
    end

    it 'does not work with anything else' do
      expect(described_class.valid_env_vars?('FOO')).to be_falsey
      expect(described_class.valid_env_vars?([['FOO']])).to be_falsey
    end
  end

  describe '#valid_url?' do
    it 'can match a valid url' do
      expect(described_class.valid_url?('http://google.com')).to be_truthy
    end

    it 'can match with an expected scheme' do
      expect(described_class.valid_url?('redis://localhost', scheme: 'redis')).to be_truthy
      expect(described_class.valid_url?('https://localhost', scheme: 'redis')).to be_falsey
    end
  end
end
