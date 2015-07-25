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

class TestClientCreate < ParseTestCase
  def stubbed_client(&_block)
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      yield(stub)
    end

    client = Parse.create(
      logger: Logger.new(STDERR).tap do |l|
        l.level = Logger::ERROR
      end
    ) do |b|
      b.adapter :test, stubs
    end

    [stubs, client]
  end

  def test_retries
    VCR.use_cassette('test_client_retries') do
      stubs, client = stubbed_client do |stub|
        (@client.max_retries + 1).times do
          stub.get('/') do
            [500, {}, {
              'code' => Parse::Protocol::ERROR_TIMEOUT }.to_json
            ]
          end
        end
      end

      assert_raises(Parse::ParseProtocolError) do
        client.request('/')
      end

      stubs.verify_stubbed_calls
    end
  end

  def test_retries_json_error
    VCR.use_cassette('test_client_retries_json_error') do
      stubs, client = stubbed_client do |stub|
        stub.get('/') { [500, {}, '<HTML>this is not json</HTML>'] }
        stub.get('/') { [200, {}, '{"foo":100}'] }
      end

      assert_equal({ 'foo' => 100 }, client.request('/'))

      stubs.verify_stubbed_calls
    end
  end

  def test_retries_server_error
    VCR.use_cassette('test_client_retries_server_error') do
      stubs, client = stubbed_client do |stub|
        stub.get('/') { [500, {}, '{}'] }
        stub.get('/') { [200, {}, '{"foo":100}'] }
      end

      assert_equal({ 'foo' => 100 }, client.request('/'))

      stubs.verify_stubbed_calls
    end
  end

  def test_wraps_connection_errors
    VCR.use_cassette('test_client_wraps_connection_errors') do
      _stubs, client = stubbed_client do |stub|
        stub.get('/') { raise Faraday::Error::ConnectionFailed, 'message' }
      end

      error = assert_raises(Parse::ConnectionError) { client.request('/') }

      assert_equal 'message', error.message
    end
  end

  def test_not_retries_404
    VCR.use_cassette('test_client_retries_404') do
      _stubs, client = stubbed_client do |stub|
        stub.get('/') { [404, {}, 'Not found'] }
        stub.get('/') { [200, {}, '{"foo":100}'] }
      end

      assert_raises(Parse::ParseProtocolError) do
        client.request('/')
      end
    end
  end

  def test_not_retries_404_with_correct_json
    VCR.use_cassette('test_client_retries_404_correct') do
      _stubs, client = stubbed_client do |stub|
        stub.get('/') { [404, {}, '{"foo":100}'] }
        stub.get('/') { [200, {}, '{"foo":100}'] }
      end

      assert_raises(Parse::ParseProtocolError) do
        client.request('/')
      end
    end
  end

  def test_empty_response
    VCR.use_cassette('test_client_empty_response') do
      stubs, client = stubbed_client do |stub|
        stub.get('/') { [403, {}, 'nonparseable'] }
      end

      # some json parsers return nil instead of raising
      JSON.stubs(:parse).returns(nil)

      begin
        client.request('/')
        fail 'client error response should have raised'
      rescue Parse::ParseProtocolError => e
        assert_equal 'HTTP Status 403 Body nonparseable', e.error
      end

      stubs.verify_stubbed_calls
    end
  end

  def test_simple_save
    VCR.use_cassette('test_client_simple_save') do
      test_save = Parse::Object.new('TestSave', nil, @client)
      test_save['foo'] = 'bar'
      test_save.save

      assert_equal test_save['foo'], 'bar'
      assert_equal test_save[Parse::Protocol::KEY_CREATED_AT].class, String
      assert_equal test_save[Parse::Protocol::KEY_OBJECT_ID].class, String
    end
  end

  def test_update
    VCR.use_cassette('test_client_update') do
      foo = Parse::Object.new('TestSave', nil, @client)
      foo['age'] = 20
      foo.save

      assert_equal foo['age'], 20
      assert_equal foo[Parse::Protocol::KEY_UPDATED_AT], nil

      foo['age'] = 40
      orig = foo.dup
      foo.save

      assert_equal foo['age'], 40
      assert_equal foo[Parse::Protocol::KEY_UPDATED_AT].class, String

      # only difference should be updatedAt
      orig_assoc = orig.reject { |k, _v| k == Parse::Protocol::KEY_UPDATED_AT }.to_a
      foo_assoc = foo.reject { |k, _v| k == Parse::Protocol::KEY_UPDATED_AT }.to_a
      assert_equal foo_assoc, orig_assoc
    end
  end

  def test_server_update
    VCR.use_cassette('test_client_server_update') do
      foo = Parse::Object.new('TestSave', nil, @client).save
      foo['name'] = 'john'
      foo.save

      bar = Parse.get('TestSave', foo.id, @client) # pull it from the server
      assert_equal bar['name'], 'john'
      bar['name'] = 'dave'
      bar.save

      bat = Parse.get('TestSave', foo.id, @client)
      assert_equal bat['name'], 'dave'
    end
  end

  def test_destroy
    VCR.use_cassette('test_client_destroy') do
      d = Parse::Object.new('toBeDeleted', nil, @client)
      d['foo'] = 'bar'
      d.save
      d.parse_delete

      assert_equal d.keys.length, 0
    end
  end

  def test_get_missing
    VCR.use_cassette('test_client_get_missing') do
      e = assert_raises(Parse::ParseProtocolError) do
        Parse.get('SomeClass', 'someIdThatDoesNotExist', @client)
      end
      assert_equal '101: object not found for get: SomeClass:someIdThatDoesNotExist', e.message
    end
  end
end
