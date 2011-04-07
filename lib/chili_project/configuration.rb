# ChiliProject is a project management system.
# Copyright (C) 2010-2011 The ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module ChiliProject
  class Configuration < Hash
    def initialize(options={})
      load(options || {})
    end

    def [](key)
      if self.has_key?(key) && defaults[key] && defaults[key].respond_to?(:deep_merge)
        if defaults[key].respond_to?(:deep_merge)
          defaults[key].deep_merge(super)
        else
          super
        end
      else
        super || defaults[key]
      end
    end

    def all
      # This a rather slow operation. This should only be used for
      # introspection or debugging.
      defaults.deep_merge(self)
    end

    def defaults
      self.class.defaults
    end

    def self.defaults
      @defaults ||= {}
    end

    def load(options={})
      filename = options[:file] || File.join(Rails.root, 'config', 'configuration.yml')
      env = options[:env] || Rails.env

      self.clear
      self.merge! load_from_yaml(filename, env) if File.file?(filename)
      load_deprecated_email_configuration(env)

      # initialize email configuration
      if self['email_delivery']
        ActionMailer::Base.perform_deliveries = true
        self['email_delivery'].each_pair do |k, v|
          v.symbolize_keys! if v.respond_to?(:symbolize_keys!)
          ActionMailer::Base.send("#{k}=", v)
        end
      end
    end
  private
    def load_from_yaml(filename, env)
      yaml = YAML::load_file(filename)

      if yaml.is_a?(Hash)
        yaml[env] || {}
      else
        $stderr.puts "#{filename} is not a valid ChiliProject configuration file"
        exit 1
      end
    end

    def load_deprecated_email_configuration(env)
      deprecated_email_conf = File.join(Rails.root, 'config', 'email.yml')
      if File.file?(deprecated_email_conf)
        if self['email_delivery']
          warn "Ignoring deprecated email configuration in config/email.yml as we already have a configuration in config/configuration.yml"
        else
          warn "Storing outgoing emails configuration in config/email.yml is deprecated. You should now store it in config/configuration.yml using the email_delivery setting."
          self.merge!({'email_delivery' => load_from_yaml(deprecated_email_conf, env)})
        end
      end

      # Compatibility mode for those who copy email.yml over configuration.yml
      %w(delivery_method smtp_settings sendmail_settings).each do |key|
        if value = self.delete(key)
          self['email_delivery'] ||= {}
          self['email_delivery'][key] = value
        end
      end
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  Configuration.defaults.deep_merge!({
    # Some external storage paths
    'attachments_storage_path' => "#{RAILS_ROOT}/files",
    'themes_storage_path' => ["#{Rails.public_path}/themes"],

    # Database adapter commands
    'scm_bazaar_command' => 'bzr',
    'scm_cvs_command' => 'cvs',
    'scm_darcs_command' => 'darcs',
    'scm_git_command' => 'git',
    'scm_mercurial_command' => 'hg',
    'scm_subversion_command' => 'svn',

    # Autologin cookie defaults:
    'autologin_cookie_name' => 'autologin',
    'autologin_cookie_path' => '/',
    'autologin_cookie_secure' => false
  })
end
