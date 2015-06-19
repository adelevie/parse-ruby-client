require 'helper'

class TestFile < ParseTestCase
  def test_file_equality
    file_1 = @client.file('url' => 'http://foobar')
    file_2 = @client.file('url' => 'http://foobar')
    file_3 = @client.file('url' => 'http://foobar2')

    assert_equal file_1, file_2
    refute_equal file_1, file_3
  end

  def test_file_hash
    file_1 = @client.file('url' => 'http://foobar')
    assert_equal file_1.url.hash, file_1.hash
  end

  def test_file_save
    VCR.use_cassette('test_file_text_save') do
      data = {
        body: 'Hello World!',
        local_filename: 'hello.txt',
        content_type: 'text/plain'
      }
      tf = @client.file(data)
      tf.save

      assert tf.local_filename
      assert tf.url
      assert tf.parse_filename
      assert tf.body
      assert tf.to_json
      assert_equal String, tf.body.class
    end
  end

  def test_image_save
    VCR.use_cassette('test_file_image_save') do
      data = {
        body: IO.read('test/parsers.jpg'),
        local_filename: 'parsers.jpg',
        content_type: 'image/jpeg'
      }
      tf = @client.file(data)
      tf.save

      assert tf.local_filename
      assert tf.url
      assert tf.parse_filename
      assert tf.body
      assert tf.to_json
    end
  end

  def test_associate_with_object
    VCR.use_cassette('test_file_image_associate_with_object') do
      data = {
        body: IO.read('test/parsers.jpg'),
        local_filename: 'parsers.jpg',
        content_type: 'image/jpeg'
      }
      tf = @client.file(data)
      tf.save

      assert tf.local_filename
      assert tf.url
      assert tf.parse_filename
      assert tf.body
      assert tf.to_json

      object = Parse::Object.new('ShouldHaveFile', nil, @client)
      object['photo'] = tf
      object.save

      assert object['photo']
      assert object['objectId']

      assert object.refresh.save
    end
  end
end
