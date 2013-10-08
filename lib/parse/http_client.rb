module Parse
  class HttpClient
    class TimeoutError < StandardError; end

    attr_accessor :base_url, :headers

    def initialize(base_url=nil, headers = {})
      @base_url = base_url
      @headers = headers
    end

    def build_query(hash)
      hash.to_a.map{|k, v| "#{k}=#{v}"}.join('&')
    end

    def request(method, uri, headers, options)
      NotImplementedError.new("Subclass responsibility")
    end
  end

  class NetHttpClient < HttpClient
    class NetHttpResponseWrapper
      def initialize(response) @response = response end
      def status() @response.code.to_i end
      def body() @response.read_body end
    end

    def request(method, uri, headers, options)
      request_class = eval("Net::HTTP::#{method.to_s.capitalize}")
      uri = "#{uri}?#{options[:query]}" if options[:query]
      request = request_class.new(uri, @headers.dup.update(headers))
      request.body = options[:data] if options.has_key?(:data)
      NetHttpResponseWrapper.new(
        @client.start do
          @client.request(request)
        end
      )
    end

    def base_url=(url)
      @base_url = url
      @client = Net::HTTP.new(@base_url.sub('https://', ''), 443)
      @client.use_ssl = true
    end
  end

  class PatronHttpClient < HttpClient
    def initialize(base_url=nil, headers = {})
      super
      @session = Patron::Session.new
      @session.timeout = 30
      @session.connect_timeout = 30
      @session.headers.update(@headers)
    end

    def build_query(hash)
      Patron::Util.build_query_pairs_from_hash(hash).join('&')
    end

    def request(method, uri, headers, options)
      @session.request(method, uri, headers, options)
    rescue Patron::TimeoutError => e
      raise HttpClient::TimeoutError.new(e)
    end

    def base_url
      @session.base_url
    end

    def base_url=(url)
      @session.base_url = url
    end

    def headers
      @session.headers
    end

    def headers=(hash)
      @session.headers = hash
    end
  end

  DEFAULT_HTTP_CLIENT = defined?(JRUBY_VERSION) ? NetHttpClient : PatronHttpClient
end
