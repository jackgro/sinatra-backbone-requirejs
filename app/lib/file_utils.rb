module Sinatra::FileUtils

  def write_tempfile(file, temp)
    file[:tempfile].rewind # Rewind before reading
    temp.write(file[:tempfile].read) # Write to the temp file
    temp.rewind # Rewind in order to be read
  end

  def delete_tempfile(temp_file)
    #close! calls #close AND #unlink. #unlink deletes the file
    temp_file.close!
  end

  def file_response(api_response)
    # Set content-disposition and content-type headers to match file from API
    if defined? api_response.headers
      headers 'content-disposition' => api_response.headers[:content_disposition] if api_response.headers[:content_disposition]
      content_type api_response.headers[:content_type] if api_response.headers[:content_type]
    elsif content = JSON.parse(api_response)
      api_response = content['errors']
    end
    api_response
  end

  def pdf_response(api_response)
    # Set content-disposition and content-type headers to match file from API
    # Remove "attachment; " from content-disposition for IE8 iframe use
    if defined? api_response.headers
      headers 'content-disposition' => api_response.headers[:content_disposition].gsub("attachment; ", "") if api_response.headers[:content_disposition]
      content_type api_response.headers[:content_type] if api_response.headers[:content_type]
    elsif content = JSON.parse(api_response)
      api_response = content['errors']
    end
    api_response
  end

end
