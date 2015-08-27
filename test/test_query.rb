require 'helper'

class TestQuery < ParseTestCase
  def setup
    super
    @q = Parse::Query.new('TestQuery', @client)
  end

  EMPTY_QUERY_RESPONSE = { Parse::Protocol::KEY_RESULTS => [] }

  def test_add_constraint
    @q.add_constraint('points', 5)
    assert_equal 5, @q.where['points']

    @q.add_constraint('player', '$regex' => 'regex voodoo')
    assert_equal @q.where['player'], '$regex' => 'regex voodoo'

    @q.add_constraint('multiple', 'first' => 1)
    @q.add_constraint('multiple', 'second' => 2)
    expected_result = { 'first' => 1, 'second' => 2 }
    assert_equal expected_result, @q.where['multiple']
  end

  def test_related_to
    pointer = Parse::Pointer.new(class_name: 'Post', parse_object_id: '1234')
    @q.related_to('comments', pointer)

    refute_nil @q.where['$relatedTo']
    assert_equal pointer, @q.where['$relatedTo']['object']
    assert_equal @q.where['$relatedTo']['key'], 'comments'
  end

  def test_eq
    @q.eq('points', 5)
    assert_equal @q.where, 'points' => 5

    @q.eq('player', 'michael@jordan.com')
    assert_equal @q.where, 'points' =>  5, 'player' => 'michael@jordan.com'
  end

  def test_eq_hash
    @q.eq('points' => 5)
    expected_result = { 'points' => 5 }
    assert_equal expected_result, @q.where

    @q.eq('player' => 'michael@jordan.com')
    expected_result = { 'points' =>  5, 'player' => 'michael@jordan.com' }
    assert_equal expected_result, @q.where
  end

  def test_eq_pointerize
    VCR.use_cassette('test_query_eq_pointerize') do
      foo = @client.object('Foo', nil)
      foo.save
      bar = @client.object('Bar', 'foo' => foo.pointer, 'bar' => 'bar')
      bar.save

      assert_equal 'bar', @client.query('Bar').eq('foo', foo.pointer).get.first['bar']
      assert_equal 'bar', @client.query('Bar').eq('foo', foo).get.first['bar']
    end
  end

  def test_not_eq
    @q.not_eq('points', 5)
    expected_result = { 'points' => { '$ne' => 5 } }
    assert_equal expected_result, @q.where

    @q.not_eq('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$ne' => 5 }, 'player' => { '$ne' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_regex
    @q.regex('points', 5)
    expected_result = { 'points' => { '$regex' => 5 } }
    assert_equal expected_result, @q.where

    @q.regex('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$regex' => 5 }, 'player' => { '$regex' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_less_than
    @q.less_than('points', 5)
    expected_result = { 'points' => { '$lt' => 5 } }
    assert_equal expected_result, @q.where

    @q.less_than('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$lt' => 5 }, 'player' => { '$lt' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_less_eq
    @q.less_eq('points', 5)
    expected_result = { 'points' => { '$lte' => 5 } }
    assert_equal expected_result, @q.where

    @q.less_eq('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$lte' => 5 }, 'player' => { '$lte' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_greather_than
    @q.greater_than('points', 5)
    expected_result = { 'points' => { '$gt' => 5 } }
    assert_equal expected_result, @q.where

    @q.greater_than('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$gt' => 5 }, 'player' => { '$gt' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_greather_eq
    @q.greater_eq('points', 5)
    expected_result = { 'points' => { '$gte' => 5 } }
    assert_equal expected_result, @q.where

    @q.greater_eq('player', 'michael@jordan.com')
    expected_result = { 'points' => { '$gte' => 5 }, 'player' => { '$gte' => 'michael@jordan.com' } }
    assert_equal expected_result, @q.where
  end

  def test_value_in
    @q.value_in('points', [5])
    expected_result = { 'points' => { '$in' => [5] } }
    assert_equal expected_result, @q.where

    @q.value_in('player', ['michael@jordan.com'])
    expected_result = { 'points' => { '$in' => [5] }, 'player' => { '$in' => ['michael@jordan.com'] } }
    assert_equal expected_result, @q.where
  end

  def test_value_not_in
    @q.value_not_in('points', [5])
    expected_result = { 'points' => { '$nin' => [5] } }
    assert_equal expected_result, @q.where

    @q.value_not_in('player', ['michael@jordan.com'])
    expected_result = { 'points' => { '$nin' => [5] }, 'player' => { '$nin' => ['michael@jordan.com'] } }
    assert_equal expected_result, @q.where
  end

  def test_exists
    @q.exists('points', true)
    expected_result = { 'points' => { '$exists' => true } }
    assert_equal expected_result, @q.where

    @q.exists('player', true)
    expected_result = { 'points' => { '$exists' => true }, 'player' => { '$exists' => true } }
    assert_equal expected_result, @q.where
  end

  def test_does_not_exist
    @q.exists('points', false)
    expected_result = { 'points' => { '$exists' => false } }
    assert_equal expected_result, @q.where

    @q.exists('player', false)
    expected_result = { 'points' => { '$exists' => false }, 'player' => { '$exists' => false } }
    assert_equal expected_result, @q.where
  end

  def test_limit_skip
    VCR.use_cassette('test_query_limit_skip') do
      @q.limit = 2
      @q.skip = 3

      query_matcher = has_entries(limit: 2, skip: 3)
      Parse::Client.any_instance.expects(:request).with(
        anything, :get, nil, query_matcher).returns(EMPTY_QUERY_RESPONSE)
      @q.get
    end
  end

  def test_count
    VCR.use_cassette('test_query_count') do
      @client.object('Post', nil).save
      @q = @client.query('Post')
      @q.count

      results = @q.get
      assert results['count'] > 0
    end
  end

  def test_first
    VCR.use_cassette('test_query_first') do
      assert @client.query('Post').first
    end
  end

  def test_include
    VCR.use_cassette('test_query_include') do
      post_1 = Parse::Object.new('Post', nil, @client)
      post_1['title'] = 'foo'
      post_1.save

      post_2 = Parse::Object.new('Post', nil, @client)
      post_2['title'] = 'bar'
      post_2['other'] = post_1.pointer
      post_2.save

      q = Parse::Query.new('Post', @client)
      q.eq('objectId', post_2.parse_object_id)
      q.include = 'other'

      assert_equal 'foo', q.get.first['other']['title']
    end
  end

  def test_keys
    VCR.use_cassette('test_keys', :record => :new_episodes) do
      post = Parse::Object.new('Post', nil, @client)
      post['title'] = 'foo'
      post['name'] = 'This is cool'
      post.save

      q = Parse::Query.new('Post', @client)
      q.eq('objectId', post.parse_object_id)
      q.keys = 'title'

      assert_equal(false, q.get.first.include?('name'))
    end
  end

  def test_or
    VCR.use_cassette('test_query_or') do
      foo = Parse::Object.new('Post', nil, @client)
      # can't be really random since we're using VCR to pre-record
      foo['random'] = 7
      foo.save
      foo_query = Parse::Query.new('Post', @client).eq('random', foo['random'])
      assert_equal 1, foo_query.get.size

      bar = Parse::Object.new('Post', nil, @client)
      bar['random'] = 5
      bar.save
      bar_query = Parse::Query.new('Post', @client).eq('random', bar['random'])
      assert_equal 1, foo_query.get.size

      query = foo_query.or(bar_query)
      assert_equal 2, query.get.size
    end
  end

  def test_in_query
    outer_query = Parse::Query.new('Outer', @client)
    inner_query = Parse::Query.new('Inner', @client)
    inner_query.eq('foo', 'bar')
    outer_query.in_query('inner', inner_query)
    assert_equal({ 'inner' => { '$inQuery' => { 'className' => 'Inner', 'where' => { 'foo' => 'bar' } } } }, outer_query.where)
  end

  def test_large_value_in_xget
    VCR.use_cassette('test_query_xget') do
      post = Parse::Object.new('Post', nil, @client)
      post.save

      other_post = Parse::Object.new('Post', nil, @client)
      other_post.save

      assert_equal [post], Parse::Query.new('Post', @client).value_in('objectId', [post.id] + 5000.times.map { 'x' }).get
    end
  end

  def test_bad_response
    VCR.use_cassette('test_query_bad_response') do
      Parse::Client.any_instance.expects(:request).returns('crap')
      assert_raises(Parse::ParseError) do
        Parse::Query.new('Post', @client).get
      end
    end
  end

  def test_contains_all
    VCR.use_cassette('test_query_contains_all') do
      # ensure cacti from the previous test to not hang around
      q = Parse::Query.new('Cactus', @client)
      cacti = q.get
      cacti.each(&:parse_delete)
      # end ensure

      cactus = Parse::Object.new('Cactus', nil, @client)
      cactus['array'] = [1, 2, 5, 6, 7]
      cactus.save

      second_cactus = Parse::Object.new('Cactus', nil, @client)
      second_cactus['array'] = [3, 4, 5, 6]
      second_cactus.save

      contains_query = Parse::Query.new('Cactus', @client).contains_all('array', [5, 6])
      assert_equal 2, contains_query.get.size

      with_one_query = Parse::Query.new('Cactus', @client).contains_all('array', [1, 5, 6])
      assert_equal 1, with_one_query.get.size
      assert_equal [cactus], with_one_query.get

      with_four_query = Parse::Query.new('Cactus', @client).contains_all('array', [4, 5, 6])
      assert_equal 1, with_four_query.get.size
      assert_equal [second_cactus], with_four_query.get

      with_nine_query = Parse::Query.new('Cactus', @client).contains_all('array', [9])
      assert_equal 0, with_nine_query.get.size
    end
  end

  def test_installations
    skip('Cannot perform query on installation objects without master key')

    VCR.use_cassette('test_query_installations') do
      assert @client.query(Parse::Protocol::CLASS_INSTALLATION).get
    end
  end

  def test_users
    VCR.use_cassette('test_query_users') do
      assert @client.query(Parse::Protocol::CLASS_USER).get
    end
  end

  def test_order_by_ascending
    VCR.use_cassette('test_query_order_by_ascending') do
      users = @client.query(Parse::Protocol::CLASS_USER).tap do |q|
        q.order_by = 'username'
        q.limit = 3
      end.get

      # check if they are ordered in ascending order
      assert users.map(&:to_h).map { |o| o['username'] }.each_cons(2).all? { |a, b| (a <=> b) <= 0 }
    end
  end

  def test_order_by_descending
    VCR.use_cassette('test_query_order_by_descending') do
      users = @client.query(Parse::Protocol::CLASS_USER).tap do |q|
        q.order_by = 'username'
        q.order = :descending
        q.limit = 3
      end.get

      # check if they are ordered in descending order
      assert users.map(&:to_h).map { |o| o['username'] }.each_cons(2).all? { |a, b| (b <=> a) <= 0 }
    end
  end

  def test_order_attribute_should_be_accessible
    @q.order = :ascending
    assert_equal :ascending, @q.order
  end
end
