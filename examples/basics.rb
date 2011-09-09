require 'vfs'

# Preparing temporary dir for sample and cleaning it before starting.
sandbox = $sandbox || '/tmp/vfs_sandbox'.to_dir.destroy

# Let's create simple Hello World project.
project = sandbox['hello_world']            # Our Hello World project.

project['readme.txt'].write 'My shiny App'  # Writing readme file, note that parent dirs
                                            # where created automatically.

# File operations.
readme = project['readme.txt']

# Checking that it's all ok with our readme.
p readme.name                               # => readme.txt
p readme.path                               # => /.../readme.txt
p readme.exist?                             # => true
p readme.file?                              # => true
p readme.dir?                               # => false
p readme.size                               # => 12
p readme.created_at                         # => 2011-09-09 13:20:43 +0400
p readme.updated_at                         # => 2011-09-09 13:20:43 +0400

# Reading.
p readme.read                               # => "My shiny App"
readme.read{|chunk| p chunk}                # => "My shiny App"

# Writing.
readme.append "2 + 2 = 4"
p readme.size                               # => 21

readme.write "My shiny App v2"              # Writing new version of readme.
p readme.read                               # => "My shiny App v2"

readme.write{|s| s.write "My shiny App v3"} # Writing another new version of readme.
p readme.read                               # => "My shiny App v3"

# Copying & Moving.
readme.copy_to project['docs/readme.txt']   # Copying to ./docs folder.
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => true

readme.move_to project['docs/readme.txt']   # Moving to ./docs folder.
p project['docs/readme.txt'].exist?         # => true
p readme.exist?                             # => false


# Dir operations.
project.file('Rakefile').create             # Creating empty Rakefile.

# Checking our project exists and not empty.
p project.exist?                            # => true
p project.empty?                            # => false

# Listing dir content.
p project.entries                           # => [/.../docs, .../Rakefile]
p project.files                             # => [/.../Rakefile]
p project.dirs                              # => [/.../docs]
project.entries do |entry|                  # => ["docs", false]
  p [entry.name, entry.file?]               # => ["Rakefile", true]
end
p project.include?('Rakefile')              # => true

# Copying & Moving, let's create another project by cloning our hello_world.
project.copy_to sandbox['another_project']
p sandbox['another_project'].entries        # => [/.../docs, .../Rakefile]

# Cleaning sandbox.
sandbox.destroy