class Ssh
  attr_reader :config
  
  
  def setstat(path, options)
    remote do |sh, sftp|
      sftp.setstat! path, options
    end
  end
  
  

  
  protected
    def generate_tmp_dir_name
      "/tmp/ssh_tmp_dir_#{rand(10**6)}"
    end
  
end