require 'test_helper'

class Zencoder::HTTP::NetHTTPTest < Test::Unit::TestCase

  context Zencoder::HTTP::NetHTTP do

    context "call options" do
      should "request with timeout" do
        stub_request(:post, "https://example.com")
        Timeout.expects(:timeout).with(0.001)
        Zencoder::HTTP::NetHTTP.post('https://example.com', :timeout => 1)
      end

      should "request without timeout" do
        stub_request(:post, "https://example.com")
        Timeout.stubs(:timeout).raises(Exception)
        assert_nothing_raised do
          Zencoder::HTTP::NetHTTP.post('https://example.com', :timeout => nil)
        end
      end

      should "add params to the query string if passed" do
        stub_request(:post, "https://example.com/path?some=param")
        Zencoder::HTTP::NetHTTP.post('https://example.com/path', {:params => {:some => 'param'}})
      end

      should "add params to the existing query string if passed" do
        stub_request(:post,'https://example.com/path?original=param&some=param')
        Zencoder::HTTP::NetHTTP.post('https://example.com/path?original=param', {:params => {:some => 'param'}})
      end

      should "add headers" do
        stub_request(:post,'https://example.com/path').with(:headers => {'some' => 'header'})
        Zencoder::HTTP::NetHTTP.post('https://example.com/path', {:headers => {:some => 'header'}})
      end

      should "add the body to the request" do
        stub_request(:post, 'https://example.com/path').with(:body => '{"some": "body"}')
        Zencoder::HTTP::NetHTTP.post('https://example.com/path', {:body => '{"some": "body"}'})
      end
    end

    context "SSL verification" do
      setup do
        @cert_store = stub(:add_file => true, :add_path => true, :flags= => true, :set_default_paths => true)
        @http_stub = stub(:use_ssl= => true, :request => true, :verify_mode= => true, :cert_store= => true, :cert_store => @cert_store)
        ::Net::HTTP.expects(:new).returns(@http_stub)
      end

      context "when set to skip ssl verification" do
        should "not verify" do
          @http_stub.expects(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
          Zencoder::HTTP::NetHTTP.post('https://example.com/path', :skip_ssl_verify => true)
        end

        should "not setup a custom cert store" do
          @http_stub.expects(:cert_store=).never
          Zencoder::HTTP::NetHTTP.post('https://example.com/path', :skip_ssl_verify => true)
        end
      end

      context "when set to do ssl verification" do
        should "setup a custom cert store" do
          @http_stub.expects(:cert_store=)
          Zencoder::HTTP::NetHTTP.post('https://example.com/path')
        end

        should "set the default paths on the custom cert store" do
          @cert_store.expects(:set_default_paths)
          Zencoder::HTTP::NetHTTP.post('https://example.com/path')
        end

        should "set the ca_file when it is passed in" do
          @cert_store.expects(:add_file).with("/foo/bar/baz.crt")
          Zencoder::HTTP::NetHTTP.post('https://example.com/path', :ca_file => "/foo/bar/baz.crt")
        end

        should "set the ca_path when it is passed in" do
          @cert_store.expects(:add_path).with("/foo/bar/")
          Zencoder::HTTP::NetHTTP.post('https://example.com/path', :ca_path => "/foo/bar/")
        end
      end

    end

    context ".post" do
      should "POST to specified body to the specified path" do
        stub_request(:post, 'https://example.com').with(:body => '{}')
        Zencoder::HTTP::NetHTTP.post('https://example.com', :body => '{}')
      end

      should "POST with an empty body if none is provided" do
        stub_request(:post, 'https://example.com').with(:body => '')
        Zencoder::HTTP::NetHTTP.post('https://example.com')
      end
    end

    context ".put" do
      should "PUT to specified body to the specified path" do
        stub_request(:put, 'https://example.com').with(:body => '{}')
        Zencoder::HTTP::NetHTTP.put('https://example.com', :body => '{}')
      end

      should "PUT with an empty body if none is provided" do
        stub_request(:put, 'https://example.com').with(:body => '')
        Zencoder::HTTP::NetHTTP.put('https://example.com')
      end
    end

    context ".get" do
      should "GET to specified body to the specified path" do
        stub_request(:get, 'https://example.com')
        Zencoder::HTTP::NetHTTP.get('https://example.com')
      end
    end

    context ".delete" do
      should "DELETE to specified body to the specified path" do
        stub_request(:delete, 'https://example.com')
        Zencoder::HTTP::NetHTTP.delete('https://example.com')
      end
    end
  end

end
