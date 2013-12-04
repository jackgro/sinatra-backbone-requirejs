module Sinatra::HttpUtils

  def post_data
    data = params
    data.delete("splat")
    data.delete("captures")
    data
  end

  # Makes it possible to use backbone's built-in save method.
  # Backbone by default sends data in the request body whereas
  # our server expects typical form data.
  # If the request is a POST or PUT, we merge the request body
  # into the params to be sent to the server.
  def parse_content_body
    if put_or_post? && request.content_type.include?("application/json")
      body_params = request.body.read
      parsed = body_params && body_params.length >= 2 ? JSON.parse(body_params) : nil
      params.merge!(parsed)
    end
  end

  def put_or_post?
    request.request_method == "PUT" || request.request_method == "POST"
  end

  def json_settings
    # Prevent some browsers (IE) from caching
    cache_control :private, :no_cache, :no_store, :max_age => 0
    content_type 'application/json'
  end

  def html_settings
    # IE needs text/html (parsed as JSON later) or it prompts for file download
    content_type 'text/html'
  end

  def update_cookies(response)
    # Refresh cookie expirations
    return unless response.code === 200
    [:ISLOGGEDIN, :PID, :FULLNAME, :EMAIL, :CS, :INSTITUTION_ID, :EXPIRATION, :PRODUCTS, :scope_name, :scope_type, :scope_id, :scope_position, :scope_institution, :applications, :p_filter_type, :p_filter_value, :app_filter_url, :app_filters].each do |val|
      if val == :PRODUCTS and cookies[val]
        if cookies[val] =~ /bycommittee/
          new_val = ("bycommittee," + cookies[val].gsub(/bycommittee,?/, "")).chomp(",")
          cookies[val] = new_val
        end
      else
        cookies[val] = CGI::unescape cookies[val] if cookies[val]
      end
    end
  end

  def verify_authentication
    unless logged_in?
      request.path_info.match(/apply\/(.+)/) do |app_id|
        redirect "https://account#{server_environment_suffix}.interfolio.com/login?apply=#{app_id.captures.first}"
      end
      redirect "/" unless request.path_info === "/"
    end
  end

  def adjust_path(path)
    redirect path if logged_in?
  end

  def get_user_name
    CGI::unescape cookies[:FULLNAME] if cookies and cookies[:FULLNAME] and !cookies[:FULLNAME].empty?
  end

  def get_user(id = nil)
    url = id ? "byc/users/#{id}" : "byc-search/users/current"
    response = api_get url
    user_info = JSON.parse(response)
    if defined? user_info["user"]
      user_info = user_info["user"]
    else
      user_info = {}
    end
  end

  def logged_in?
    cookies and cookies[:PID] and !cookies[:PID].empty?
  end

  def next_app(current, app_list)
    i = app_list.index(current)
    next_id = (app_list.length > (i + 1)) ? app_list[i + 1] : app_list[0]
    "../#{next_id}/read"
  end

  def prev_app(current, app_list)
    i = app_list.index(current)
    prev_id = (i > 0) ? app_list[i - 1] : app_list[app_list.length - 1]
    "../#{prev_id}/read"
  end

  def server_environment_suffix
    settings.server_suffix
  end

end
