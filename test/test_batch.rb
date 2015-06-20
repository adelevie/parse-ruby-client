require 'helper'

class TestBatch < ParseTestCase
  def test_initialize
    client = Parse::Client.new
    batch = Parse::Batch.new(client)
    assert_equal batch.class, Parse::Batch
    assert_equal client, batch.client
  end

  def test_add_request
    batch = Parse::Batch.new(@client)
    batch.add_request(
      method: 'POST',
      path: '/1/classes/GameScore',
      body: {
        score: 1337,
        playerName: 'Sean Plott'
      })
    batch.add_request(
      method: 'POST',
      path: '/1/classes/GameScore',
      body: {
        score: 1338,
        playerName: 'ZeroCool'
      })
    assert_equal batch.requests.class, Array
    assert_equal batch.requests.length, 2
    assert_equal batch.requests.first[:path], '/1/classes/GameScore'
  end

  def test_protocol_uri
    uri = Parse::Protocol.batch_request_uri
    assert_equal uri, '/1/batch'
  end

  def test_run
    VCR.use_cassette('test_batch_run') do
      batch = Parse::Batch.new(@client)
      batch.add_request(
        'method' => 'POST',
        'path' => '/1/classes/GameScore',
        'body' => {
          'score' => 1337,
          'playerName' => 'Sean Plott'
        })
      resp = batch.run!
      assert_equal resp.length, batch.requests.length
      assert resp.first['success']
      assert_equal resp.first['success']['objectId'].class, String
    end
  end

  def test_create_object
    VCR.use_cassette('test_batch_create_object') do
      objects = [1, 2, 3, 4, 5].map do |i|
        p = Parse::Object.new('BatchTestObject', nil, @client)
        p['foo'] = "#{i}"
        p
      end
      batch = Parse::Batch.new(@client)
      objects.each do |obj|
        batch.create_object(obj)
      end
      resp = batch.run!
      assert_equal Array, resp.class
      assert_equal resp.first['success']['objectId'].class, String
    end
  end

  def test_update_object
    VCR.use_cassette('test_batch_update_object') do
      objects = [1, 2, 3, 4, 5].map do |i|
        p = Parse::Object.new('BatchTestObject', nil, @client)
        p['foo'] = "#{i}"
        p.save
        p
      end
      objects.map do |obj|
        obj['foo'] = 'updated'
      end
      batch = Parse::Batch.new(@client)
      objects.each do |obj|
        batch.update_object(obj)
      end
      resp = batch.run!
      assert_equal Array, resp.class
      assert_equal resp.first['success']['updatedAt'].class, String
    end
  end

  def test_update_nils_delete_keys
    VCR.use_cassette('test_batch_update_nils_delete_keys') do
      post = Parse::Object.new('BatchTestObject', nil, @client)
      post['foo'] = '1'
      post.save

      post['foo'] = nil
      batch = Parse::Batch.new(@client)
      batch.update_object(post)
      batch.run!

      refute post.refresh.keys.include?('foo')
    end
  end

  def test_delete_object
    VCR.use_cassette('test_batch_delete_object') do
      objects = [1, 2, 3, 4, 5].map do |i|
        p = Parse::Object.new('BatchTestObject', nil, @client)
        p['foo'] = "#{i}"
        p.save
        p
      end
      batch = Parse::Batch.new(@client)
      objects.each do |obj|
        batch.delete_object(obj)
      end
      resp = batch.run!

      assert resp.is_a?(Array)

      assert_equal true, resp.all? { |item| item.key? 'success' }
    end
  end
end
