module Sinatra::ApiUtils

  def endpoint
    endpoint = params[:splat].first
    endpoint += "?#{request.query_string}" if request.query_string
    endpoint
  end

  def logo_upload_endpoint(type, id)
    "byc-search/#{type}/#{id}/logo"
  end

  def attachment_upload_endpoint(id)
    "byc-search/positions/#{id}/file_attachments"
  end

  def document_upload_endpoint(position, application)
    "byc-search/positions/#{position}/applications/#{application}/documents"
  end

  def api_url(resource)
    url = settings.api_server + settings.api_path + resource
    puts url
    url
  end

  def api_get(resource)
    begin
      response = RestClient.get(api_url(resource), { :cookies => cookies })
      update_cookies(response)
    rescue => e
      response = handle_error(e, "api_get")
    end
    response
  end

  def api_post(resource, data)
    begin
      response = RestClient.post(api_url(resource), data, { :cookies => cookies } )
      update_cookies(response)
    rescue => e
      response = handle_error(e, "api_post")
    end
    response
  end

  def api_put(resource, data)
    begin
      response = RestClient.put(api_url(resource), data, { :cookies => cookies } )
      update_cookies(response)
    rescue => e
      response = handle_error(e, "api_put")
    end
    response
  end

  def api_delete(resource)
    begin
      response = RestClient.delete(api_url(resource), { :cookies => cookies })
      update_cookies(response)
    rescue => e
      response = handle_error(e, "api_delete")
    end
    response
  end

  def handle_error(e, call_name)
    puts e.response.code
    if e.response.code === 500
      puts "Error contacting API in #{call_name}"
      puts e.response
      response = "{\"MESSAGE\": \"We're sorry, but something went wrong. We're looking into the issue and hope to have ByCommittee restored shortly.\"}"
    else
      response = e.response
    end
    response
  end

end
