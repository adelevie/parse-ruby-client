require 'helper'

class TestFile < Test::Unit::TestCase
  def setup
    Parse.init
  end

  def test_file_save
    VCR.use_cassette('test_text_file_save', :record => :new_episodes) do
      tf = Parse::File.new(:body => "Hello World!", :local_filename => "hello.txt")
      tf.save

      assert tf.local_filename
      assert tf.url
      assert tf.parse_filename
      assert tf.body
      assert tf.to_json
    end
  end

end