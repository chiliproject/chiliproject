#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module Redmine
  module Utils
    class << self
      # Returns the relative root url of the application
      def relative_url_root
       if defined?(Rails) && Rails::VERSION::MAJOR < 3
        ActionController::Base.respond_to?('relative_url_root') ?
          ActionController::Base.relative_url_root.to_s :
          ActionController::AbstractRequest.relative_url_root.to_s
       else
         nil
       end
      end

      # Sets the relative root url of the application
      def relative_url_root=(arg)
       if defined?(Rails) && Rails::VERSION::MAJOR < 3
        if ActionController::Base.respond_to?('relative_url_root=')
          ActionController::Base.relative_url_root=arg
        else
          ActionController::AbstractRequest.relative_url_root=arg
        end
       else
         nil
       end
      end

      # Generates a n bytes random hex string
      # Example:
      #   random_hex(4) # => "89b8c729"
      def random_hex(n)
        ActiveSupport::SecureRandom.hex(n)
      end
    end
  end
end
