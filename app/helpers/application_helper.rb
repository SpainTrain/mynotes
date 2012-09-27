require 'securerandom'

module ApplicationHelper
  def oauth_url callback_uri="#{request.protocol}#{request.host_with_port}#{request.path}"
    session[:state_nonce] = SecureRandom.hex 32
    callback_uri = "#{callback_uri}?state=#{session[:state_nonce]}"
    session[:redirect_uri] = callback_uri
    oauth_info = Rails.configuration.oauth_info
    url = "#{oauth_info[:oauth_url]}/authorize"
    url << "?client_id=#{oauth_info[:client_id]}"
    url << "&response_type=#{oauth_info[:response_type]}"
    url << "&redirect_uri=#{callback_uri}"
    url << "&scope=#{oauth_info[:scope]}"
    url << "&state=#{session[:state_nonce]}"
    url << "&update=#{oauth_info[:update]}"
    return URI::encode url
  end
end
