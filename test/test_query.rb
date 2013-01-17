require 'helper'

Parse.init

class TestQuery < Test::Unit::TestCase

  def test_get
    VCR.use_cassette('test_get', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      post["title"] = "foo"
      post.save

      q = Parse.get("Post", post.id)

      assert_equal q.id, post.id
      assert_equal q["title"], post["title"]
    end
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
    VCR.use_cassette('test_limit_skip', :record => :new_episodes) do
      q = Parse::Query.new "TestQuery"
      q.limit = 2
      q.skip = 3
      query_matcher = has_entries(:limit =>  2, :skip => 3)
      Parse::Client.any_instance.expects(:request).with(anything, :get, nil, query_matcher).returns({}.to_json)
      q.get
    end
  end

  def test_count
    VCR.use_cassette('test_count', :record => :new_episodes) do
      q = Parse::Query.new "TestQuery"
      q.count = true
      query_matcher = has_entries(:count => true)
      Parse::Client.any_instance.expects(:request).with(anything, :get, nil, query_matcher).returns({}.to_json)
      q.get
    end
  end

  def test_include
    VCR.use_cassette('test_include', :record => :new_episodes) do
      post_1 = Parse::Object.new "Post"
      post_1['title'] = 'foo'
      post_1.save

      post_2 = Parse::Object.new "Post"
      post_2['title'] = 'bar'
      post_2['other'] = post_1.pointer
      post_2.save

      q = Parse::Query.new "Post"
      q.eq('objectId', post_2.parse_object_id)
      q.include = 'other'

      assert_equal 'foo', q.get.first['other']['title']
    end
  end

  def test_or
    #VCR.use_cassette('test_or', :record => :new_episodes) do
      foo = Parse::Object.new "Post"
      foo["random"] = rand
      foo.save
      foo_query = Parse::Query.new("Post").eq("random", foo["random"])
      assert_equal 1, foo_query.get.size

      bar = Parse::Object.new "Post"
      bar["random"] = rand
      bar.save
      bar_query = Parse::Query.new("Post").eq("random", bar["random"])
      assert_equal 1, foo_query.get.size

      query = foo_query.or(bar_query)
      assert_equal 2, query.get.size
    #end
  end

  def test_in_query
    outer_query = Parse::Query.new "Outer"
    inner_query = Parse::Query.new "Inner"
    inner_query.eq("foo", "bar")
    outer_query.in_query("inner", inner_query)
    assert_equal({"inner"=>{"$inQuery"=>{"className"=>"Inner", "where"=>{"foo"=>"bar"}}}}, outer_query.where)
  end
end
