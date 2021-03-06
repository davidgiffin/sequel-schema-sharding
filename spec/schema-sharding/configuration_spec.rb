require 'spec_helper'
require 'sequel/schema-sharding/configuration'

describe Sequel::SchemaSharding::Configuration do

  let(:config) { Sequel::SchemaSharding::Configuration.new(:boom, 'spec/fixtures/test_db_config.yml') }

  describe '#logical_shard_configs' do
    it 'returns a hash representing the mapping between logical and physical shards' do
      shards = config.logical_shard_configs('boof')

      expect(shards.length).to eq(20)

      shards.each_pair do |key, value|
        if key <= 10
          expect(value).to eq('shard1')
        elsif key > 10
          expect(value).to eq('shard2')
        end
      end
    end

    context 'when the number of shards not the same' do
      it 'raises an exception' do
        config.stubs(:number_of_shards).returns(1)
        expect {
          config.logical_shard_configs('boof')
        }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#physical_shard_configs' do
    it 'returns a hash representing the configuration for all physical shards' do
      shards = config.physical_shard_configs

      expect(shards.length).to eq(2)

      i = 1
      shards.each_pair do |key, value|
        expect(value['host']).to eq('127.0.0.1')
        expect(value['database']).to eq("sequel_boom_shard#{i}")
        expect(value['username']).to eq('postgres')
        expect(value['password']).to eq('boomboomkaboom')
        expect(value['port']).to eq(5432)
        expect(value['replicas']).to eq([{'host' => '127.0.0.1',
                                         'database' => 'sequel_boom_shard2',
                                         'port' => 5432,
                                         'username' => 'postgres',
                                         'password' => 'boomboomkaboom'}]) if key == 'shard2'

        i += 1
      end
    end
  end
end
