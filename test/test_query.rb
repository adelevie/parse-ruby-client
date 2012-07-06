require 'helper'

Parse.init

class TestQuery < Test::Unit::TestCase

  def test_get
    post = Parse::Object.new "Post"
    post["title"] = "foo"
    post.save

    q = Parse.get("Post", post.id)

    assert_equal q.id, post.id
    assert_equal q["title"], post["title"]
  end

  def test_add_contraint
    # I know this method *should* be private.
    # But then it would be a PITA to test.
    # I'd rather test this one method than pointlessly test many others.
    # Thus is life.

    q = Parse::Query.new "TestQuery"
    q.add_constraint("points", 5)
    assert_equal q.where["points"], 5
    q.add_constraint("player", { "$regex" => "regex voodoo"})
    assert_equal q.where["player"], { "$regex" => "regex voodoo"}
  end

  def test_eq
    q = Parse::Query.new "TestQuery"
    q.eq("points", 5)
    assert_equal q.where, {"points" => 5}
    q.eq("player", "michael@jordan.com")
    assert_equal q.where, {"points" =>  5, "player" => "michael@jordan.com"}
  end

  def test_limit_skip
    q = Parse::Query.new "TestQuery"
    q.limit = 2
    q.skip = 3
    query_matcher = has_entries(:limit =>  2, :skip => 3)
    Parse::Client.any_instance.expects(:request).with(anything, :get, nil, query_matcher).returns({}.to_json)
    q.get
  end

  def test_count
    q = Parse::Query.new "TestQuery"
    q.count = true
    query_matcher = has_entries(:count => true)
    Parse::Client.any_instance.expects(:request).with(anything, :get, nil, query_matcher).returns({}.to_json)
    q.get
  end
end
