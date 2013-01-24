require 'helper'

class TestFile < Test::Unit::TestCase
  def setup
    Parse.init
  end

  def test_text_file_save
    VCR.use_cassette('test_text_file_save', :record => :new_episodes) do
      tf = Parse::TextFile.new(:text => "Testing Hello World!", :filename => "hello_test.txt")
      tf.save

      assert tf.name
      assert tf.url
      assert tf.filename
      assert tf.text
    end
  end

end