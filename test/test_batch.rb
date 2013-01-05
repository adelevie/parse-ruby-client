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

end
