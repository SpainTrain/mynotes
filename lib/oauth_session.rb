class OauthSession
  @@ssl = Rails.configuration.ssl_info
  @@oauth_info = Rails.configuration.oauth_info

  def initialize code, callback
    data = {
      :grant_type => @@oauth_info[:grant_type],
      :code => code,
      :client_id => @@oauth_info[:client_id],
      :client_secret => @@oauth_info[:client_secret],
      :redirect_uri => callback
    }
    if not do_auth data
      #Raise exception
    end
  end

  #destructive method that merges latter hash into the former hash
  def merge_gems curr_gems, new_gems
    if new_gems == nil
      return curr_gems
    end

    #check for new data from server
    new_gems.each do |id, gem| 
      if curr_gems.key? id        
        curr_gem = curr_gems[id]
        if gem[:last_saved] > curr_gem[:last_saved]
          curr_gems[id] = get_gem gem[:gem_instance_id]
        elsif gem[:last_saved] < curr_gem[:last_saved]
          #update gem to server
          curr_gems[id] = update_gem curr_gem
        else
          #same data, do nothing
        end
      else
        #get gem and place into curr_gems
        curr_gems[id] = get_gem gem[:gem_instance_id]
      end
    end

    #check for new local data that needs to be saved
    curr_gems.reject{|id, gem| gem != nil and gem.key?:gem_instance_id}.each do |id, gem|
      #save gem to server and update local note_id
      new_gem = create_gem curr_gems.delete(id)
      new_id = new_gem[:gem_instance_id].split('#')[2]
      curr_gems[new_id] = new_gem
    end
  end

  def update_gem note_hash
    check_validity
    req_hash = {
      "gem" => {
        "info" => {
          "gem_instance_id" => note_hash[:gem_instance_id],
          "gem_instance_name" => note_hash[:title],
          "gem_template_id" => @@oauth_info[:template_id],
          "updated_timestamp" => note_hash[:remote_timestamp]
        },
        "data" => {
          "note_title" => note_hash[:title],
          "note_note" => note_hash[:body],
          "note_note_url" => note_hash[:url]
        }
      }
    }
    response = api_put note_hash[:gem_instance_id], req_hash
    return gem_to_note response["gem"]
  end

  def create_gem note_hash
    check_validity
    req_hash = {
      "gem" => {
        "info" => {
          "gem_instance_name" => note_hash[:title],
          "gem_template_id" => @@oauth_info[:template_id]
        },
        "data" => {
          "note_title" => note_hash[:title],
          "note_note" => note_hash[:body],
          "note_note_url" => note_hash[:url]
        }
      }
    }
    response = api_post req_hash
    gem_hash = response["gem"]
    note_hash.merge!({
      :last_saved => Time.at(gem_hash["info"]["updated_timestamp"].to_f/1000),
      :remote_timestamp => gem_hash["info"]["updated_timestamp"],
      :gem_instance_id => gem_hash["info"]["gem_instance_id"]
    })
    return note_hash
  end

  def destroy_gem gem_instance_id
    check_validity
    response = api_delete gem_instance_id
    return gem_to_note response["gem"]
  end

  #takes note gem id and returns mynotes formatted gem data
  def get_gem gem_instance_id
    check_validity
    response = api_get gem_instance_id
    return gem_to_note response["gem"]
  end

  #takes optional template-id, returns hash of gem (in mynotes format)
  def gem_list template_id=@@oauth_info[:template_id]
    check_validity
    response = api_get "my"
    gems = response["gems"]

    to_return = {}
    if gems == nil then return to_return end
    gems.delete_if { |gem| gem["gem_template_id"] != template_id }
    gems.each { |gem| to_return[gem["gem_instance_id"].split("#")[2]] = {
      :title => gem["gem_instance_name"],
      :gem_instance_id => gem["gem_instance_id"],
      :last_saved => Time.at(gem["updated_timestamp"].to_f/1000)
    }}
    return to_return
  end

  protected
  #Check expiration and refresh self if invalid
  def check_validity
    if @expires_at < Time.new
      debugger
      do_refresh
    end
  end

  #Perform either initial auth or refresh, return boolean for success
  def do_auth data_hash
    url = "#{@@oauth_info[:oauth_url]}/access_token"
    ssl = @@ssl
    headers = {:content_type => "application/x-www-form-urlencoded;charset=UTF-8"}

    conn = Faraday.new(:url => url, :ssl => ssl) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.response :logger
    end

    response = conn.post url, data_hash, headers
    res_hash = JSON.parse response.body
    @access_token = res_hash["access_token"]
    @refresh_token = res_hash["refresh_token"]
    @expires_at = res_hash["expires_in"].seconds.from_now
    return true
  end

  #Refresh token
  def do_refresh
    data = {
      :grant_type => "refresh_token",
      :refresh_token => @refresh_token,
      :client_id => @@oauth_info[:client_id],
      :client_secret => @@oauth_info[:client_secret]
    }
    if not do_auth data
      #Raise Exception
    end
  end

  #transform a gem hash into a mynotes hash
  def gem_to_note gem_hash
    if gem_hash == nil then return nil end
    return {
      :title  => gem_hash["data"]["note_title"],
      :body   => gem_hash["data"]["note_note"],
      :last_saved => Time.at(gem_hash["info"]["updated_timestamp"].to_f/1000),
      :remote_timestamp => gem_hash["info"]["updated_timestamp"],
      :gem_instance_id => gem_hash["info"]["gem_instance_id"]
    }
  end

  #takes everything after <url>/gems/ and returns a hash of the GET response
  def api_get url_suffix
    url = URI::encode "#{@@oauth_info[:api_url]}/gems/#{url_suffix}"
    data = {:client_id => @@oauth_info[:client_id]}
    headers = {:Authorization => "Bearer #{@access_token}"}

    conn = get_conn url
    return JSON.parse(conn.get(url, data, headers).body)
  end

  def api_put url_suffix, data_hash
    url = URI::encode "#{@@oauth_info[:api_url]}/gems/#{url_suffix}?client_id=#{@@oauth_info[:client_id]}"
    data = JSON.generate data_hash
    headers = {:Authorization => "Bearer #{@access_token}"}

    conn = get_conn url
    return JSON.parse(conn.put(url, data, headers).body)
  end

  def api_post data_hash
    url = URI::encode "#{@@oauth_info[:api_url]}/gems?client_id=#{@@oauth_info[:client_id]}"
    data = JSON.generate data_hash
    headers = {:Authorization => "Bearer #{@access_token}"}

    conn = get_conn url
    return JSON.parse(conn.post(url, data, headers).body)
  end

  def api_delete url_suffix
    url = URI::encode "#{@@oauth_info[:api_url]}/gems/#{url_suffix}?client_id=#{@@oauth_info[:client_id]}"
    headers = {:Authorization => "Bearer #{@access_token}"}

    conn = get_conn url
    return JSON.parse(conn.delete(url, {}, headers).body)
  end

  #get connection for get, put, post, delete (not authorization)
  def get_conn url
    return Faraday.new(:url => url, :ssl => @@ssl) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :logger
    end
  end
end
