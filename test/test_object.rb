require 'helper'

class TestObject < Test::Unit::TestCase
  def setup
    Parse.init
  end

  def test_new?
  	post = Parse::Object.new "Post"
  	assert_equal post.new?, true
  	post.save
  	assert_equal post.new?, false
  end

  def test_id
    post = Parse::Object.new "Post"
    assert_equal post.id, nil
    post["title"] = "hello world"
    post.save
    assert_equal post.id.class, String
  end

  def test_created_at
    post = Parse::Object.new "Post"
    assert_equal post.created_at, nil
    post.save
    assert_equal post.created_at.class, DateTime
  end

  def test_updated_at
    post = Parse::Object.new "Post"
    assert_equal post.updated_at, nil
    post["title"] = "hello"
    post.save
    assert_equal post.updated_at, nil
    post["title"] = "hello 2"
    post.save
    assert_equal post.updated_at.class, DateTime
  end

  def test_parse_delete
    post = Parse::Object.new "Post"
    post.save
    assert_equal post.id.class, String

    q = Parse.get("Post", post.id)
    assert_equal q.id, post.id

    post.parse_delete

    assert_raise Parse::ParseError do
      q = Parse.get("Post", post.id)
    end
  end

end
