require File.expand_path('../../test_helper', __FILE__)

class ProjectDropTest < ActiveSupport::TestCase
  def setup
    @project = Project.generate!
    User.current = @user = User.generate!
    @role = Role.generate!
    Member.generate!(:principal => @user, :project => @project, :roles => [@role])
    @drop = @project.to_liquid
  end

  context "drop" do
    should "be a ProjectDrop" do
      assert @drop.is_a?(ProjectDrop), "drop is not a ProjectDrop"
    end
  end


  context "#name" do
    should "return the project name" do
      assert_equal @project.name, @drop.name
    end
  end

  context "#identifier" do
    should "return the project identifier" do
      assert_equal @project.identifier, @drop.identifier
    end
  end

  should "only load an object if it's visible to the current user" do
    assert User.current.logged?
    assert @project.visible?

    @private_project = Project.generate!(:is_public => false)

    assert !@private_project.visible?, "Project is visible"
    @private_drop = ProjectDrop.new(@private_project)
    assert_equal nil, @private_drop.instance_variable_get("@object")
    assert_equal nil, @private_drop.name
  end
end
