module MediawikiApi
  # testing helpers
  module RequestHelpers
    def api_url
      'http://localhost/api.php'
    end

    def index_url
      'http://localhost/w/index.php'
    end

    def mock_token
      'token123'
    end

    def stub_api_request(method, params)
      params = params.each.with_object({}) { |(k, v), p| p[k] = v.to_s }

      stub_request(method, api_url).
        with((method == :post ? :body : :query) => params.merge(format: 'json'))
    end

    def stub_action_request(action, params = {})
      method = params.delete(:http_method) || :post

      stub_api_request(method, params.merge(action: action, token: mock_token))
    end

    def stub_login_request(username, password)
      login_token = 't123'

      stub_request(:get, api_url).
        with(query: { format: 'json', action: 'query', meta: 'tokens', type: 'login' }).
        to_return(body: { query: { tokens: { logintoken: login_token } } }.to_json)

      params = { action: 'login', lgname: username, lgpassword: password, lgtoken: login_token }

      stub_api_request(:post, params)
    end

    def stub_token_request(type, warning = nil)
      response = { query: { tokens: { "#{type}token" => mock_token } } }
      response[:warnings] = { type => { '*' => [warning] } } unless warning.nil?

      stub_api_request(:get, action: 'query', meta: 'tokens', type: type).
        to_return(body: response.to_json)
    end
  end
end
