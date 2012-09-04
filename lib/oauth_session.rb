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


  def gem_list filters
    
  end
end
