#-- encoding: UTF-8
require File.expand_path('../test_helper', File.dirname(__FILE__))

class TestingTest < Test::Unit::TestCase
  def setup
    Engines::Testing.set_fixture_path
    @filename = File.join(Engines::Testing.temporary_fixtures_directory, 'testing_fixtures.yml')
    File.delete(@filename) if File.exists?(@filename)
  end
  
  def teardown
    File.delete(@filename) if File.exists?(@filename)
  end

  def test_should_copy_fixtures_files_to_tmp_directory
    assert !File.exists?(@filename)
    Engines::Testing.setup_plugin_fixtures
    assert File.exists?(@filename)
  end
end