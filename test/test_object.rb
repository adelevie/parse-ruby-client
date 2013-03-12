require 'helper'

class TestObject < Test::Unit::TestCase
  def setup
    Parse.init
  end

  def test_new?
    VCR.use_cassette('test_new_object', :record => :new_episodes) do
    	post = Parse::Object.new "Post"
    	assert_equal post.new?, true
    	post.save
    	assert_equal post.new?, false
    end
  end

  def test_object_id
    VCR.use_cassette('test_object_id', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      assert_equal post.id, nil
      post["title"] = "hello world"
      post.save
      assert_equal post.id.class, String
    end
  end

  def test_pointer
    VCR.use_cassette('test_pointer', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      assert_nil post.pointer

      post.save
      pointer = post.pointer
      assert_equal pointer.class_name, post.class_name
      assert_equal pointer.parse_object_id, post.parse_object_id
    end
  end

  def test_created_at
    VCR.use_cassette('test_created_at', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      assert_equal post.created_at, nil
      post.save
      assert_equal post.created_at.class, DateTime
    end
  end

  def test_updated_at
    VCR.use_cassette('test_updated_at', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      assert_equal post.updated_at, nil
      post["title"] = "hello"
      post.save
      assert_equal post.updated_at, nil
      post["title"] = "hello 2"
      post.save
      assert_equal post.updated_at.class, DateTime
    end
  end

  def test_parse_delete
    VCR.use_cassette('test_parse_delete', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      post.save
      assert_equal post.id.class, String

      q = Parse.get("Post", post.id)
      assert_equal q.id, post.id

      post.parse_delete

      assert_raise Parse::ParseProtocolError do
        q = Parse.get("Post", post.id)
      end
    end
  end

  def test_deep_parse
    VCR.use_cassette('test_deep_parse', :record => :new_episodes) do
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

  def test_deep_as_json
    VCR.use_cassette('test_deep_as_json', :record => :new_episodes) do
      other = Parse::Object.new "Post"
      other['date'] = Parse::Date.new(DateTime.now)
      assert other.as_json['date']['iso']
    end
  end

  def test_nils_delete_keys
    VCR.use_cassette('test_nils_delete_keys', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      post["title"] = "hello"
      post.save
      post["title"] = nil
      post.save
      assert_false post.refresh.keys.include?("title")
    end
  end

  def test_array_add
    VCR.use_cassette('test_array_add', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      post.array_add("chapters", "hello")
      assert_equal ["hello"], post["chapters"]
      post.save
      assert_equal ["hello"], post["chapters"]

      post.array_add("chapters", "goodbye")
      assert_equal ["hello", "goodbye"], post["chapters"]
      post.save
      assert_equal ["hello", "goodbye"], post["chapters"]
    end
  end

  def test_array_add_relation
    VCR.use_cassette('test_array_add_relation', :record => :new_episodes) do
      post = Parse::Object.new "Post"
      post.save

      comment = Parse::Object.new "Comment"
      comment.save

      post.array_add_relation("comments", comment.pointer)
      post.save

      q = Parse::Query.new("Comment")
      q.related_to("comments", post.pointer)
      comments = q.get
      assert_equal comments.first["objectId"], comment["objectId"]
    end
  end

  def test_save_with_sub_objects
    VCR.use_cassette('test_save_with_sub_objects', :record => :new_episodes) do
      bar = Parse::Object.new("Bar", "foobar" => "foobar")
      bar.save

      foo = Parse::Object.new("Foo", "bar" => bar, "bars" => [bar])
      foo.save

      assert_equal "foobar", foo['bar']['foobar']
      assert_equal bar.pointer, foo['bars'][0]

      foo = Parse::Query.new("Foo").eq("objectId", foo.id).tap { |q| q.include = 'bar,bars' }.get.first

      foo.save

      assert_equal "foobar", foo['bar']['foobar']
      assert_equal bar.pointer, foo['bars'][0]

      bar = foo['bar']
      bar['baz'] = 'baz'
      bar.save

      assert_equal 'baz', bar['baz']
    end
  end
end
