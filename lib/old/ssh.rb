class Ssh
  attr_reader :config
  
  
  def setstat(path, options)
    remote do |sh, sftp|
      sftp.setstat! path, options
    end
  end
  
end