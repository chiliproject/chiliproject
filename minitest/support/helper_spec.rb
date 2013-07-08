class HelperSpec < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior

  register_spec_type(/Helper$/, self)
end
