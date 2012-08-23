require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=
    
    def use_ssl=(flag)
      self.ca_file = '/usr/share/ca-certificates/cacert.org/cacert.org.crt'
      self.verify_mode = OpenSSL::SSL::VERIFY_NONE
      self.original_use_ssl = flag
    end
  end
end
