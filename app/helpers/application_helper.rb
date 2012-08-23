module ApplicationHelper
  def oauth_url()
    oauth_info = Rails.configuration.oauth_info
    url = oauth_info[:oauth_url]
    url << "?client_id=#{oauth_info[:client_id]}"
    url << "&response_type=#{oauth_info[:response_type]}"
    url << "&redirect_uri=#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    url << "&scope=#{oauth_info[:scope]}"
    url << "&update=#{oauth_info[:update]}"
    return URI::encode url
  end
end
