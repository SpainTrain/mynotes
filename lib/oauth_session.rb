class OauthSession
  def initialize code, callback
    @code = code
    oauth_info = Rails.configuration.oauth_info
    url = "#{oauth_info[:oauth_url]}/access_token"
    ssl = { :ca_path => '/etc/ssl/certs',
            :ca_file => '/etc/ssl/certs/ca-certificates.crt',
            :verify_mode => OpenSSL::SSL::VERIFY_NONE
    }
    data = {
      :grant_type => oauth_info[:grant_type],
      :code => @code,
      :client_id => oauth_info[:client_id],
      :client_secret => oauth_info[:client_secret],
      :redirect_uri => callback
    }
    headers = {:content_type => "application/x-www-form-urlencoded;charset=UTF-8"}

    data_str = "grant_type=#{oauth_info[:grant_type]}"
    data_str << "&\ncode=#{@code}"
    data_str << "&\nclient_id=#{oauth_info[:client_id]}"
    data_str << "&\nclient_secret=#{oauth_info[:client_secret]}"
    data_str << "&\nredirect_uri=#{callback}"
    
    conn = Faraday.new(:url => url, :ssl => ssl) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.response :logger
    end

    response = conn.post url, data, headers
    res_hash = JSON.parse response.body
    @access_token = res_hash["access_token"]
    @refresh_token = res_hash["refresh_token"]
  end
end
