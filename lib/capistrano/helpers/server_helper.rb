module ServerHelper

  def erb_eval(path)
    StringIO.new(ERB.new(File.read(path), nil, '-').result(binding))
  end

  def upload_to_server(file)
    raw_filename = file[:filename].gsub(/.erb/, '')
    file_path = "#{shared_path}/server/#{raw_filename}"
    # try to find the file locally, then fetch the gem's file
    eval_file = begin
        erb_eval("config/deploy/server/#{file[:filename]}")
    rescue
        erb_eval(File.expand_path("../../files/#{file[:filename]}", __FILE__))
    end
    upload! eval_file, file_path # upload to the remote server
    return file_path
  end

end
