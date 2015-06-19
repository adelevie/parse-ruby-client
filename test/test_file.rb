require 'helper'

class TestFile < ParseTestCase
  def test_file_save
    VCR.use_cassette('test_file_text_save') do
      tf = Parse::File.new({
                             body: 'Hello World!',
                             local_filename: 'hello.txt',
                             content_type: 'text/plain'
                           }, @client)
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
      tf = Parse::File.new({
                             body: IO.read('test/parsers.jpg'),
                             local_filename: 'parsers.jpg',
                             content_type: 'image/jpeg'
                           }, @client)
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
      tf = Parse::File.new({
                             body: IO.read('test/parsers.jpg'),
                             local_filename: 'parsers.jpg',
                             content_type: 'image/jpeg'
                           }, @client)
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
