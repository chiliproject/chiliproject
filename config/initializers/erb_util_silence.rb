if Rails::VERSION::MAJOR == 2
  require "active_support/core_ext/string/output_safety"

  class ERB
    module Util
      # see https://github.com/rails/rails/issues/7430
      def html_escape(s)
        s = s.to_s
        if s.html_safe?
          s
        else
          s.gsub(/[&"'><]/, HTML_ESCAPE).html_safe
        end
      end

      alias h html_escape

      singleton_class.send(:remove_method, :html_escape)
      module_function :html_escape, :h
    end
  end
else
  puts "You can delete this file+test now #{__FILE__}"
end
