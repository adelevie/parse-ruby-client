require 'helper'

class TestDatatypes < ParseTestCase
  def test_pointer
    data = {
      Parse::Protocol::KEY_CLASS_NAME => 'DatatypeTestClass',
      Parse::Protocol::KEY_OBJECT_ID => '12345abcd'
    }
    p = Parse::Pointer.new data

    assert_equal p.to_json, "{\"__type\":\"Pointer\",\"#{Parse::Protocol::KEY_CLASS_NAME}\":\"DatatypeTestClass\",\"#{Parse::Protocol::KEY_OBJECT_ID}\":\"12345abcd\"}"

    assert_equal 'DatatypeTestClass:12345abcd', p.to_s
  end

  def test_pointer_make
    p = Parse::Pointer.make('SomeClass', 'someId')
    assert_equal 'SomeClass', p.class_name
    assert_equal 'someId', p.id
    assert_equal p, p.pointer
  end

  def test_pointer_hash
    p = Parse::Pointer.make('SomeClass', 'someId')
    assert p.hash
  end

  def test_date
    VCR.use_cassette('test_datatypes_date') do
      date_time = Time.at(0).to_datetime
      parse_date = Parse::Date.new(date_time)

      assert_equal date_time, parse_date.value
      assert_equal '1970-01-01T00:00:00.000Z', JSON.parse(parse_date.to_json)['iso']
      assert_equal 0, parse_date <=> parse_date.dup
      assert_equal 0, Parse::Date.new(date_time) <=> Parse::Date.new(date_time).dup

      post = Parse::Object.new('Post', nil, @client)
      post['time'] = parse_date
      post.save
      q = Parse.get('Post', post.id, @client)

      # time zone from parse is utc so string formats don't compare equal,
      # also floating points vary a bit so only equality after rounding to millis is guaranteed
      assert_equal parse_date.to_time.utc.to_datetime.iso8601(3), q['time'].to_time.utc.to_datetime.iso8601(3)
    end
  end

  def test_date_with_bad_data
    assert_raises(RuntimeError) do
      Parse::Date.new(2014)
    end

    assert_raises(RuntimeError) do
      Parse::Date.new(nil)
    end
  end

  def test_date_with_time
    time = Time.parse('01/01/2012 23:59:59')
    assert_equal time, Parse::Date.new(time).to_time
  end

  def test_date_with_string
    date_string = '01/01/2012 23:59:59'
    assert_equal DateTime.parse(date_string), Parse::Date.new(date_string).value
  end

  def test_date_equality
    assert_equal Parse::Date.new(Time.at(0)), Parse::Date.new(Time.at(0))
  end

  def test_date_hash
    time = Time.at(0)
    assert_equal time.hash, Parse::Date.new(time).hash
  end

  def test_bytes
    bytes = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))
    assert_equal bytes.value, 'testing bytes!'

    pbytes = JSON.parse(bytes.to_json)
    assert_equal pbytes[Parse::Protocol::KEY_TYPE], Parse::Protocol::TYPE_BYTES
    assert_equal pbytes['base64'], Base64.encode64('testing bytes!')
  end

  def test_bytes_equality
    bytes_1 = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))
    bytes_2 = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))

    assert_equal bytes_1, bytes_2
  end

  def test_bytes_ordering
    bytes_1 = Parse::Bytes.new('base64' => Base64.encode64('xyz'))
    bytes_2 = Parse::Bytes.new('base64' => Base64.encode64('bcd'))

    assert_equal [bytes_2, bytes_1], [bytes_1, bytes_2].sort
  end

  def test_bytes_hash
    bytes = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))
    assert_equal bytes.value.hash, bytes.hash
  end

  def test_bytes_metod_missing
    bytes = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))
    assert bytes.split
  end

  def test_bytes_respond_to
    bytes = Parse::Bytes.new('base64' => Base64.encode64('testing bytes!'))
    assert bytes.respond_to?(:split)
  end

  def test_increment
    amount = 5
    increment = Parse::Increment.new amount

    assert_equal increment.to_json, "{\"__op\":\"Increment\",\"amount\":#{amount}}"
  end

  def test_increment_equality
    incr_1 = Parse::Increment.new 5
    incr_2 = Parse::Increment.new 5

    assert_equal incr_1, incr_2
  end

  def test_increment_hash
    incr_1 = Parse::Increment.new 5
    assert_equal incr_1.amount.hash, incr_1.hash
  end

  def test_geopoint
    VCR.use_cassette('test_datatypes_geopoint') do
      data = {
        'longitude' => 40.0,
        'latitude' => -30.0
      }

      geopoint = Parse::GeoPoint.new data
      assert_equal '(-30.0, 40.0)', geopoint.to_s

      pgp = JSON.parse(geopoint.to_json)
      assert_equal pgp['longitude'], data['longitude']
      assert_equal pgp['latitude'], data['latitude']
      assert_equal pgp[Parse::Protocol::KEY_TYPE], Parse::Protocol::TYPE_GEOPOINT

      post = Parse::Object.new('Post', nil, @client)
      post['location'] = geopoint
      post.save

      q = Parse.get('Post', post.id, @client)
      assert_equal geopoint, q['location']
    end
  end

  def test_geopoint_init_symbols
    assert Parse::GeoPoint.new(longitude: 40.0, latitude: -30.0)
  end

  def test_geopoint_hash
    geopoint = Parse::GeoPoint.new(longitude: 40.0, latitude: -30.0)
    expected_result = geopoint.longitude.hash ^ geopoint.latitude.hash
    assert_equal expected_result, geopoint.hash
  end

  def test_array_op
    op = Parse::ArrayOp.new(Parse::Protocol::KEY_ADD, ['something'])
    assert_equal Parse::Protocol::KEY_ADD, op.operation
    assert_equal ['something'], op.objects
  end

  def test_array_op_equality
    op_1 = Parse::ArrayOp.new(Parse::Protocol::KEY_ADD, ['something'])
    op_2 = Parse::ArrayOp.new(Parse::Protocol::KEY_ADD, ['something'])
    op_3 = Parse::ArrayOp.new(Parse::Protocol::KEY_REMOVE, ['something'])
    op_4 = Parse::ArrayOp.new(Parse::Protocol::KEY_REMOVE, ['something else'])

    assert_equal op_1, op_2
    refute_equal op_1, op_3
    refute_equal op_3, op_4
  end

  def test_array_op_hash
    op = Parse::ArrayOp.new(Parse::Protocol::KEY_ADD, ['something'])
    expected_result = op.operation.hash ^ op.objects.hash
    assert_equal expected_result, op.hash
  end
end
