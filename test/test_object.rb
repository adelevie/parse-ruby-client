require 'helper'

class TestObject < ParseTestCase
  def test_new?
    VCR.use_cassette('test_object_new') do
      post = Parse::Object.new('Post', nil, @client)
      assert_equal post.new?, true
      post.save
      assert_equal post.new?, false
    end
  end

  def test_object_id
    VCR.use_cassette('test_object_id') do
      post = Parse::Object.new('Post', nil, @client)
      assert_equal post.id, nil
      post['title'] = 'hello world'
      post.save
      assert post.id.is_a?(String)
    end
  end

  def test_pointer
    VCR.use_cassette('test_object_pointer') do
      post = Parse::Object.new('Post', nil, @client)
      assert_nil post.pointer

      post.save
      pointer = post.pointer
      assert_equal pointer.class_name, post.class_name
      assert_equal pointer.parse_object_id, post.parse_object_id
    end
  end

  def test_get
    VCR.use_cassette('test_object_get') do
      post = Parse::Object.new('Post', nil, @client)
      post['title'] = 'foo'
      post.save

      obj = Parse.get('Post', post.id, @client)

      assert_equal obj.id, post.id
      assert_equal obj['title'], post['title']
    end
  end

  def test_equality
    VCR.use_cassette('test_object_equality') do
      foo_1 = Parse::Object.new('Foo', nil, @client)
      foo_2 = Parse::Object.new('Foo', nil, @client)

      assert foo_1 != foo_2
      assert foo_1 == foo_1

      foo_1.save
      assert foo_1 != foo_2
      assert foo_2 != foo_1
      assert foo_1.pointer != foo_2
      assert foo_2 != foo_1.pointer
      foo_2.save

      assert foo_1 == foo_1.dup
      assert foo_1 != foo_2

      assert foo_1 == foo_1.pointer
      assert foo_1.pointer == foo_1

      other_foo_1 = Parse.get('Foo', foo_1.id, @client)
      assert foo_1 == other_foo_1
    end
  end

  def test_created_at
    VCR.use_cassette('test_object_created_at') do
      post = Parse::Object.new('Post', nil, @client)
      assert_equal post.created_at, nil
      post.save
      assert_equal post.created_at.class, DateTime
    end
  end

  def test_updated_at
    VCR.use_cassette('test_object_updated_at') do
      post = Parse::Object.new('Post', nil, @client)
      assert_equal post.updated_at, nil
      post['title'] = 'hello'
      post.save
      assert_equal post.updated_at, nil
      post['title'] = 'hello 2'
      post.save
      assert_equal post.updated_at.class, DateTime
    end
  end

  def test_parse_delete
    VCR.use_cassette('test_object_parse_delete') do
      post = Parse::Object.new('Post', nil, @client)
      post.save
      assert_equal post.id.class, String

      q = Parse.get('Post', post.id, @client)
      assert_equal q.id, post.id

      post.parse_delete

      assert_raises(Parse::ParseProtocolError) do
        q = Parse.get('Post', post.id, @client)
      end
    end
  end

  def test_deep_parse
    VCR.use_cassette('test_object_deep_parse') do
      other = Parse::Object.new('Post', nil, @client)
      other.save
      post = Parse::Object.new('Post', nil, @client)
      post['other'] = other.pointer
      post.save

      q = Parse.get('Post', post.id, @client)
      assert_equal Parse::Pointer, q['other'].class
      assert_equal other.pointer, q['other']
    end
  end

  def test_acls_arent_objects
    VCR.use_cassette('test_object_acls_arent_objects') do
      data = { 'ACL' => { '*' => { 'read' => true } } }
      post = Parse::Object.new('Post', data, @client)
      assert_equal Hash, post['ACL'].class
      post.save
      assert_equal Hash, post.refresh['ACL'].class

      post = Parse.get('Post', post.id, @client)
      assert_equal Hash, post['ACL'].class
    end
  end

  def test_to_json_uses_rest_api_hash
    post = Parse::Object.new('Post', nil, @client)
    hash = { 'post' => [post] }
    parsed = JSON.parse(hash.to_json)
    assert_equal 'Post', parsed['post'][0][Parse::Protocol::KEY_CLASS_NAME]
  end

  def test_deep_as_json
    VCR.use_cassette('test_object_deep_as_json') do
      other = Parse::Object.new('Post', nil, @client)
      other['date'] = Parse::Date.new(DateTime.now)
      assert other.as_json['date']['iso']
    end
  end

  def test_deep_as_json_with_array
    VCR.use_cassette('test_object_deep_as_json') do
      other = Parse::Object.new('Post', nil, @client)
      other['date'] = Parse::Date.new(DateTime.now)
      other['array'] = [1, 2]
      assert other.as_json['date']['iso']
    end
  end

  def test_nils_delete_keys
    VCR.use_cassette('test_object_nils_delete_keys') do
      post = Parse::Object.new('Post', nil, @client)
      post['title'] = 'hello'
      post.save
      post['title'] = nil
      post.save
      refute post.refresh.keys.include?('title')
    end
  end

  def test_saving_nested_objects
    VCR.use_cassette('test_object_saving_nested_objects') do
      post = Parse::Object.new('Post', nil, @client)
      post['comment'] = Parse::Object.new(
        'Comment', { 'text' => 'testing' }, @client)
      assert_raises(ArgumentError) { post.save }
    end
  end

  def test_boolean_values_as_json
    post = Parse::Object.new('Post', nil, @client)
    post['read'] = false
    post['published'] = true
    safe_json_hash = JSON.parse post.safe_hash.to_json
    assert_equal false, safe_json_hash['read']
    assert_equal true, safe_json_hash['published']
  end

  def test_saving_boolean_values
    VCR.use_cassette('test_object_saving_boolean_values') do
      post = Parse::Object.new('Post', nil, @client)
      post['read'] = false
      post['published'] = true
      post.save
      retrieved_post = Parse::Query.new('Post', @client)
                       .eq('objectId', post['objectId']).get.first
      assert_equal false, retrieved_post['read']
      assert_equal true, retrieved_post['published']
    end
  end

  def test_array_add
    VCR.use_cassette('test_object_array_add') do
      post = @client.object('Post')
      post.array_add('chapters', 'hello')
      assert_equal ['hello'], post['chapters']
      post.save
      assert_equal ['hello'], post['chapters']

      post.array_add('chapters', 'goodbye')
      assert_equal %w(hello goodbye), post['chapters']
      post.save
      assert_equal %w(hello goodbye), post['chapters']
    end
  end

  def test_array_remove
    VCR.use_cassette('test_object_array_remove') do
      post = @client.object('Post')
      post.array_add('chapters', 'hello')
      assert_equal ['hello'], post['chapters']
      post.save
      assert_equal ['hello'], post['chapters']

      post.array_remove('chapters', 'hello')
      assert_empty post['chapters']
      post.save
      assert_empty post['chapters']
    end
  end

  def test_array_add_pointerizing
    VCR.use_cassette('test_object_array_add_pointerizing') do
      post = Parse::Object.new('Post', nil, @client)

      data = { 'text' => 'great post!' }
      comment = Parse::Object.new('Comment', data, @client)
      comment.save
      post.array_add('comments', comment)
      assert_equal 'great post!', post['comments'][0]['text']
      post.save
      assert_equal 'great post!', post['comments'][0]['text']

      post = Parse::Query.new('Post', @client).eq('objectId', post.id).tap do |q|
        q.include = 'comments'
      end.get.first
      assert_equal 'great post!', post['comments'][0]['text']
      post.save
      assert_equal 'great post!', post['comments'][0]['text']
    end
  end

  def test_array_add_unique
    VCR.use_cassette('test_object_array_add_unique') do
      post = Parse::Object.new('Post', nil, @client)
      post.save

      data = { 'text' => 'great post!' }
      comment = Parse::Object.new('Comment', data, @client)
      comment.save

      post.array_add_unique('comments', comment)
      assert_equal 'great post!', post['comments'][0]['text']
      post.save
      assert_equal comment, post['comments'][0]

      # save returns array pointerized
      assert post['comments'][0].instance_of?(Parse::Pointer)
    end
  end

  def test_decrement
    VCR.use_cassette('test_object_decrement') do
      post = Parse::Object.new('Post', { 'count' => 1 }, @client)
      post.save

      post.decrement('count')
      assert_equal 0, post['count']
    end
  end

  def test_array_add_relation
    VCR.use_cassette('test_object_array_add_relation') do
      post = @client.object('Post')
      post.save

      comment = @client.object('Comment')
      comment.save

      post.array_add_relation('cs', comment.pointer)
      post.save

      comments = @client.query('Comment').tap do |q|
        q.related_to('cs', post.pointer)
      end.get

      assert_equal comments.first['objectId'], comment['objectId']
    end
  end

  def test_array_remove_relation
    VCR.use_cassette('test_object_array_remove_relation') do
      post = @client.object('Post')
      post.save

      comment = @client.object('Comment')
      comment.save

      post.array_add_relation('cs', comment.pointer)
      post.save

      comments = @client.query('Comment').tap do |q|
        q.related_to('cs', post.pointer)
      end.get
      assert_equal comments.first['objectId'], comment['objectId']

      post = post.refresh
      post.array_remove_relation('cs', comment.pointer)
      post.save

      comments = @client.query('Comment').tap do |q|
        q.related_to('cs', post.pointer)
      end.get
      assert_empty comments
    end
  end

  def test_save_with_sub_objects
    VCR.use_cassette('test_object_save_with_sub_objects') do
      bar = Parse::Object.new('Bar', { 'foobar' => 'foobar' }, @client)
      bar.save

      foo = Parse::Object.new('Foo', { 'bar' => bar, 'bars' => [bar] }, @client)
      foo.save

      assert_equal 'foobar', foo['bar']['foobar']
      assert_equal 'foobar', foo['bars'][0]['foobar']

      foo = Parse::Query.new('Foo', @client).eq('objectId', foo.id).tap do |q|
        q.include = 'bar,bars'
      end.get.first
      foo.save

      assert_equal 'foobar', foo['bar']['foobar']
      assert_equal 'foobar', foo['bars'][0]['foobar']

      bar = foo['bar']
      bar['baz'] = 'baz'
      bar.save

      assert_equal 'baz', bar['baz']
    end
  end
end
