Mynotes::Application.config.oauth_info = {
  :oauth_url => "https://api-sandbox.personal.com/oauth",
  :api_url => "https://api-sandbox.personal.com/api/v1",
  :client_id => "gb4gjczj2nj7gjtq545bnzv3",
  :response_type => "code",
  :template_id => "0135",
  :scope => "read_0135,write_0135,create_0135",
  :update => "true",
  :grant_type => "authorization_code",
  :client_secret => "caXZdaNE7xUHE8spT53K27uT"
}

Mynotes::Application.config.ssl_info ={
  :ca_path => '/etc/ssl/certs',
  :ca_file => '/etc/ssl/certs/ca-certificates.crt',
  :verify_mode => OpenSSL::SSL::VERIFY_NONE
}
