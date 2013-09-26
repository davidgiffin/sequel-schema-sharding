require 'spec_helper'

describe Sequel::SchemaSharding, 'Model' do

  let(:model) do
    klass = Sequel::SchemaSharding::Model('artists')
    klass.instance_eval do
      set_sharded_column :artist_id
      set_columns [:artist_id, :name]

      def by_id(id)
        shard_for(id).where(artist_id: id)
      end

      def self.implicit_table_name
        'artists'
      end
    end

    klass.class_eval do
      def this
        @this ||= model.by_id(artist_id).limit(1)
      end
    end
    klass
  end

  describe '#by_id' do
    it 'returns a valid artist by id' do
      artist = model.create(artist_id: 14, name: 'Paul')
      expect(artist.id).to_not be_nil
      read_back_artist = model.by_id(14).first
      expect(read_back_artist).to be_a(model)
      expect(read_back_artist.name).to eql('Paul')
      read_back_artist.destroy
      read_back_artist = model.by_id(14).first
      expect(read_back_artist).to be_nil
    end
  end

  describe '#create' do
    it 'creates a valid artist' do
      artist = model.create(artist_id: 234, name: 'Paul')
      expect(artist).to be_a(model)
      expect(artist.name).to eql('Paul')
      artist.destroy
    end
  end

end
