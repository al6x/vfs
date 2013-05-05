require 'vfs'

RSpec::Core::ExampleGroup.class_eval do
  def self.with_test_dir
    before do
      @test_dir = "/tmp/test_dir".to_dir

      FileUtils.rm_r test_dir.path if File.exist? test_dir.path
      FileUtils.mkdir_p test_dir.path
    end

    after do
      FileUtils.rm_r test_dir.path if File.exist? test_dir.path
      @test_dir = nil
    end
  end

  def test_dir
    @test_dir
  end
end