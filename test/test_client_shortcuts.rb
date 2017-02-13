# encoding: utf-8
require 'helper'

class TestClientShortcuts < ParseTestCase
  def test_batch
    batch = @client.batch
    assert batch.is_a? Parse::Batch
    assert_equal @client, batch.client
  end

  def test_cloud_function
    cloud_function = @client.cloud_function('whatever')
    assert cloud_function.is_a? Parse::Cloud::Function
    assert_equal @client, cloud_function.client
  end

  def test_file
    file = @client.file(body: 'Hello World!',
                        local_filename: 'hello.txt',
                        content_type: 'text/plain')
    assert file.is_a? Parse::File
    assert_equal @client, file.client
  end

  def test_object
    object = @client.object('Post')
    assert object.is_a? Parse::Object
    assert_equal @client, object.client
  end

  def test_push
    push = @client.push(alert: 'message')
    assert push.is_a? Parse::Push
    assert_equal @client, push.client
  end

  def test_query
    query = @client.query('Post')
    assert query.is_a? Parse::Query
    assert_equal @client, query.client
  end

  def test_user
    user = @client.user(username: 'foobar', password: 'whatever')
    assert user.is_a? Parse::User
    assert_equal @client, user.client
  end

  def test_application_config
    VCR.use_cassette('test_application_config') do
      assert @client.application_config
    end
  end
end
