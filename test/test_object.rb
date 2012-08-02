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

  def test_pointer
    post = Parse::Object.new "Post"
    pointer = post.pointer
    assert_equal pointer.class_name, post.class_name

    post.save
    pointer = post.pointer
    assert_equal pointer.class_name, post.class_name
    assert_equal pointer.parse_object_id, post.parse_object_id
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

  def test_deep_parse
    other = Parse::Object.new "Post"
    other.save
    post = Parse::Object.new "Post"
    post["other"] = other.pointer
    post.save

    q = Parse.get("Post", post.id)
    assert_equal Parse::Pointer, q["other"].class
    assert_equal other.pointer, q["other"]
  end

end
