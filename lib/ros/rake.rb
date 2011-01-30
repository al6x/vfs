def package *a, &b
  task *a do |task, *args|
    Ros.each_box_cached do |box|
      package = Ros::Package.new task.name
      package.configure_with &b
      package.apply_to box
    end    
  end  
end