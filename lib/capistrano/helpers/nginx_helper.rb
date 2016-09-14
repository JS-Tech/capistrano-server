module NginxHelper

  def server_name
    if subdomains = fetch(:subdomains)
      subdomains = "(?<subdomains>(" + subdomains.join("|") + ")\\.)?"
    end
    "~^(www\\.)?#{subdomains}#{url}$"
  end

  def return_url
    if fetch(:subdomains)
      "https://${subdomains}#{url}${request_uri}"
    else
      "https://#{url}${request_uri}"
    end
  end

  def ssl?
    fetch(:ssl, false)
  end

  def url
    fetch(:url, "localhost")
  end

  def default_server
    "default_server" unless fetch(:side_app, false)
  end

end
