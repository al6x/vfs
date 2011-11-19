require 'spec_helper'

describe 'Dir' do
  with_test_dir

  before do
    @path = test_dir['a/b/c']
  end

  describe 'existence' do
    it "should check only dirs" do
      @path.should_not exist
      @path.file.create
      @path.should be_file
      @path.dir.should_not exist
      @path.dir.create
      @path.should be_dir
      @path.dir.should exist
    end
  end

  it "should not respond to read and write methods" do
    -> {@path.dir.read}.should raise_error(NoMethodError)
    -> {@path.dir.write}.should raise_error(NoMethodError)
  end

  describe 'create' do
    it 'should be chainable' do
      @path.dir.create.should == @path
    end

    it 'should create parent dirs if not exists' do
      @path.parent.should_not exist
      @path.dir.create
      @path.should be_dir
    end

    it 'should silently exit if dir already exist' do
      @path.dir.create
      @path.dir.create
    end

    it 'should override existing file' do
      @path.file.create
      @path.should be_file
      @path.dir.create
      @path.should be_dir
    end

    it 'should not override existing dir with content' do
      dir = @path.dir
      dir.create
      file = dir.file :file
      file.create
      file.should exist

      dir.create
      file.should exist
    end
  end

  describe 'deleting' do
    it "should delete a file" do
      @path.file.create
      @path.dir.delete
      @path.entry.should_not exist
    end

    it "shouldn't raise if dir not exist" do
      @path.dir.delete
    end

    it 'should delete recursivelly' do
      dir = @path.dir
      dir.create
      dir.file(:file).write 'something'
      dir.dir(:dir).create.tap do |dir|
        dir.file(:file2).write 'something2'
      end

      dir.delete
      dir.should_not exist
    end

    it 'should be chainable' do
      @path.dir.delete.should == @path
    end
  end

  describe 'entries, files, dirs' do
    before do
      @path.dir('dir').create
      @path.dir('dir/another_dir').create
      @path.file('file').create
    end

    it 'entries' do
      -> {@path['non_existing'].entries}.should raise_error(Vfs::Error, /not exist/)
      @path['non_existing'].entries(bang: false).should == []
      @path.entries.to_set.should be_eql([@path.entry('dir'), @path.entry('file')].to_set)
      list = []
      @path.entries{|e| list << e}
      list.to_set.should be_eql([@path.entry('dir'), @path.entry('file')].to_set)
    end

    it 'entries with type' do
      @path.entries(type: true).to_set.should be_eql([@path.dir('dir'), @path.file('file')].to_set)
    end

    it "glob search support" do
      @path.dir('dir_a').create
      @path.file('file_a').create
      @path.dir('dir_b').create
      @path.entries('*_a').collect(&:name).sort.should == %w(dir_a file_a)
    end

    it 'should raise error if trying :entries on file' do
      @path.file('some_file').create
      -> {@path.dir('some_file').entries}.should raise_error(/File/)
    end

    it 'files' do
      @path.files.should be_eql([@path.file('file')])
    end

    it 'dirs' do
      @path.dirs.should be_eql([@path.dir('dir')])
    end

    it 'has? & include?' do
      @path.include?('dir').should be_true
      @path.include?('dir/another_dir').should be_true
      @path.include?('file').should be_true
      @path.include?('non_existing').should be_false
    end

    it 'empty?' do
      @path.empty?.should be_false
      @path.dir('empty_dir').create.empty?.should be_true
    end

    it "should threat ['**/*.rb'] as glob" do
      @path['**/*nother*'].first.name.should == 'another_dir'
    end
  end

  describe 'copying' do
    before do
      @from = @path.dir
      @from.create
      @from.file('file').write 'something'
      @from.dir('dir').create.tap do |dir|
        dir.file('file2').write 'something2'
      end
    end

    it 'should not copy to itself' do
      -> {@from.copy_to @from}.should raise_error(Vfs::Error, /itself/)
    end

    shared_examples_for 'copy_to behavior' do
      it 'should copy to file and overwrite it' do
        @from.copy_to @to.file
        @to['file'].read.should == 'something'
      end

      it 'should override files' do
        @from.copy_to @to

        @from['dir/file2'].write 'another'
        @from.copy_to @to
        @to['dir/file2'].read.should == 'another'
      end

      it 'should copy to UniversalEntry (and overwrite)' do
        @from.copy_to @to.entry

        @from.copy_to @to.entry
        @to['file'].read.should == 'something'
      end

      it "shouldn't delete existing content of directory" do
        @to.dir.create
        @to.file('existing_file').write 'existing_content'
        @to.dir('existing_dir').create
        @to.file('dir/existing_file2').write 'existing_content2'

        @from.copy_to @to
        # copied files
        @to['file'].read.should == 'something'
        @to['dir/file2'].read.should == 'something2'

        # Shouldn't delete already existing files.
        @to.file('existing_file').read.should == 'existing_content'
        @to.dir('existing_dir').should exist
        @to.file('dir/existing_file2').read.should == 'existing_content2'
      end

      it 'should be chainable' do
        @from.copy_to(@to).should == @to
      end

      it "should override without deleting other files" do
        @from.copy_to(@to).should == @to
        @to.file('other_file').write 'other'

        @from.copy_to(@to).should == @to
        @to.file('other_file').read.should == 'other'
      end

      it "should raise error if try to copy file as dir" do
        dir = @from.dir 'file'
        dir.file?.should be_true
        -> {dir.copy_to @to}.should raise_error(Vfs::Error)
      end
    end

    describe 'general copy' do
      it_should_behave_like 'copy_to behavior'

      before do
        # Prevenging usage of :efficient_dir_copy.
        # Vfs::Dir.dont_use_efficient_dir_copy = true

        @to = test_dir['to']
      end
      # after do
      #   Vfs::Dir.dont_use_efficient_dir_copy = false
      # end
    end

    # describe 'effective copy' do
    #   it_should_behave_like 'copy_to behavior'
    #
    #   before do
    #     @to = test_dir['to']
    #   end
    # end
  end

  describe 'moving' do
    it 'move_to' do
      from, to = @path.file('from'), @path.file('to')
      from.should_receive(:copy_to).with(to)
      from.should_receive(:delete).with()
      from.move_to to
    end

    it 'should be chainable' do
      from, to = @path.dir('from').create, @path.dir('to')
      from.move_to(to).should == to
    end
  end
end