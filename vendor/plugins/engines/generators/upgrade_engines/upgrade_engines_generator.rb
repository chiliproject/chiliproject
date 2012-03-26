class UpgradeEnginesGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'upgrade_engines_migration.rb', 'db/migrate', 
                          :migration_file_name => "upgrade_engines_to_1_2"
    end
  end
end