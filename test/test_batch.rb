require 'helper'

class TestBatch < Test::Unit::TestCase
  def setup
    Parse.init
  end

  def test_initialize
    batch = Parse::Batch.new
    assert_equal batch.class, Parse::Batch
  end

  def test_add_request
    batch = Parse::Batch.new
    batch.add_request({
      :method => "POST",
      :path => "/1/classes/GameScore",
      :body => {
        :score => 1337,
        :playerName => "Sean Plott"
      }
    })
    batch.add_request({
      :method => "POST",
      :path => "/1/classes/GameScore",
      :body => {
        :score => 1338,
        :playerName => "ZeroCool"
      }
    })
    assert_equal batch.requests.class, Array
    assert_equal batch.requests.length, 2
    assert_equal batch.requests.first[:path], "/1/classes/GameScore"
  end

  def test_protocol_uri
    uri = Parse::Protocol.batch_request_uri
    assert_equal uri, "/1/batch"
  end

  def test_run
    VCR.use_cassette('test_batch_run', :record => :new_episodes) do
      batch = Parse::Batch.new
      batch.add_request({
        "method" => "POST",
        "path" => "/1/classes/GameScore",
        "body" => {
          "score" => 1337,
          "playerName" => "Sean Plott"
        }
      })
      resp = batch.run!
      assert_equal resp.length, batch.requests.length
      assert resp.first["success"]
      assert_equal resp.first["success"]["objectId"].class, String
    end
  end

  def test_request_new
    request = Parse::Batch::Request.new({
      :path => "/1/classes/GameScore",
      :method => "POST"
    })
    request.body = {"score" => 1337}
    assert_equal request.class, Parse::Batch::Request
    assert_equal request.to_hash["path"], "/1/classes/GameScore"
    assert_equal request.to_hash["method"], "POST"
    assert_equal request.to_hash["body"], {"score" => 1337}
  end

  def test_request_batch
    VCR.use_cassette('test_request_batch', :record => :new_episodes) do
      request = Parse::Batch::Request.new
      request.method = "POST"
      request.path = "/1/classes/GameScore"
      request.body = {"gameScore" => 42}
      batch = Parse::Batch.new
      batch.add_request(request)
      resp = batch.run!
      assert_equal resp.length, batch.requests.length
      assert resp.first["success"]
      assert_equal resp.first["success"]["objectId"].class, String
    end
  end

end
