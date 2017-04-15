class Dispatcher
  def self.to_prepare(&block)
    ::ActiveSupport::Deprecation.warn(
      "Dispatcher.to_prepare is deprected. Use Rails.configuration.to_prepare instead.",
      caller
    )
    Rails.configuration.to_prepare(&block)
  end
end
