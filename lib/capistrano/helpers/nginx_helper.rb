module NginxHelper

  def server_name
    if subdomains = fetch(:subdomains)
      subdomains = "((" + subdomains.join("|") + ")\\.)?"
    end
    url = fetch(:url, "localhost")
    "~^(www\\.)?#{subdomains}#{url}$"
  end

  def ssl?
    fetch(:ssl, false)
  end

  def default_server
    "default_server" unless fetch(:side_app, false)
  end

  def erb_eval(path)
    StringIO.new(ERB.new(File.read(path), nil, '-').result(binding))
  end

end
