module MiniTest
  module Support
    module Helpers
      module SettingsHelper
        def with_settings(options, &block)
          saved_settings = options.keys.inject({}) {|h, k| h[k] = Setting[k].dup; h}
          options.each {|k, v| Setting[k] = v}
          yield
        ensure
          saved_settings.each {|k, v| Setting[k] = v}
        end
      end
    end
  end
end
