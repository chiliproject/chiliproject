require File.expand_path('../../minitest_helper', __FILE__)
require 'pp'

describe Project do
  fixtures :trackers

  describe 'default attributes' do
    it 'is public by default if configured' do
      with_settings :default_projects_public => '1' do
        Project.new.is_public.must_equal true
        Project.new(:is_public => false).is_public.must_equal false
      end

      with_settings :default_projects_public => '0' do
        Project.new.is_public.must_equal false
        Project.new(:is_public => true).is_public.must_equal true
      end
    end

    it "creates sequal project identifiers if configured" do
      with_settings :sequential_project_identifiers => '1' do
        # uses project-1 if no project is in the database already
        identifier = Project.next_identifier || "project-1"
        Project.new.identifier.must_equal identifier
        Project.new(:identifier => '').identifier.must_be :blank?
      end

      with_settings :sequential_project_identifiers => '0' do
        Project.new.identifier.must_be :blank?
        Project.new(:identifier => 'test').identifier.must_equal 'test'
      end
    end

    it "sets default project modules" do
      default_modules = ['issue_tracking', 'repository']
      with_settings :default_projects_modules => default_modules do
        Project.new.enabled_module_names.must_equal default_modules
      end
    end

    it "uses all trackers by default" do
      Tracker.all.must_equal Project.new.trackers
      Tracker.find(1, 3).sort_by(&:id).must_equal Project.new(:tracker_ids => [1, 3]).trackers.sort_by(&:id)
    end
  end

  it "ensures a valid identifier" do
    project = Project.new

    %w[abc ab12 ab-12 ab_12].each do |t|
      project.must have_valid(:identifier).when(t)
    end

    %w[12 new].each do |t|
      project.wont have_valid(:identifier).when(t)
    end
  end
end
