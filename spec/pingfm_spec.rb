# $Id$

require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Pingfm::Client, " with expected results" do

  before(:each) do
    @client = Pingfm::Client.new('a','b')
    @params = {'api_key' => 'a', 'user_app_key' => 'b'}
  end

  it "should validate keys successfully" do
    init_ok_response 'user.validate'

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.validate
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

  it "should list the user's services properly" do
    init_service_response

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.services
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['services'].should_not be_nil
    result['services'].should_not be_empty
    result['services'].length.should eql(2)
    result['services'].first['id'].should eql('twitter')
  end

  it "should list the user's custom triggers" do
    init_trigger_response

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.triggers
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['triggers'].should_not be_nil
    result['triggers'].should_not be_empty
    result['triggers'].length.should eql(2)
    result['triggers'].first['id'].should eql('twt')
  end

  it "should list the user's recent posts" do
    init_latest_response

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"
    @params.merge!('limit'=>5,'order'=>'DESC')

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.latest(5)
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
    result['messages'].should_not be_nil
    result['messages'].should_not be_empty
    result['messages'].length.should eql(3)
    result['messages'].first['id'].should eql('12345')
  end

  it "should post a message to the service" do
    init_ok_response 'user.post'

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"
    @params.merge!('body' => 'foo', 'title' => '',
    'post_method' => 'default', 'service' => '',
    'debug' => 0)

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.post('foo')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

  it "should post a message to the service using a trigger" do
    init_ok_response 'user.tpost'

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"
    @params.merge!('body' => 'foo', 'title' => '',
    'trigger' => 'twt', 'debug' => 0)

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.tpost('foo','twt')
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('OK')
  end

end

describe Pingfm::Client, " with error messages" do
  before(:each) do
    @client = Pingfm::Client.new('a','b')
    @params = {'api_key' => 'a', 'user_app_key' => 'b'}
  end

  it "should handle a failed validate cleanly" do
    init_fail_response 'user.validate'

    uri = URI.parse "#{Pingfm::API_URL}/#{@service_type}"

    # mock the http call
    http_resp = mock('response')
    http_resp.should_receive(:body).and_return(@response)
    Net::HTTP.should_receive(:post_form).with(uri, @params).and_return(http_resp)

    # call and verify
    result = @client.validate
    result.should_not be_empty
    result['status'].should_not be_nil
    result['status'].should eql('FAIL')
    result['message'].should_not be_nil
  end
end

# EOF
