class ModelSpec < MiniTest::Spec
  include MiniTest::Support::Helpers::SettingsHelper

  include ActiveRecord::TestFixtures
  self.fixture_path = Rails.root.join("test", "fixtures")

  register_spec_type(self) do |desc|
    desc.respond_to?(:ancestors) && desc.ancestors.include?(ActiveRecord::Base)
  end
end
