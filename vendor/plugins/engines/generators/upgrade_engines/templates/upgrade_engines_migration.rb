require 'fileutils'

class UpgradeEnginesPluginToVersion12 < ActiveRecord::Migration
  def self.up
    puts "In DB =>  Renaming 'engine_schema_info' yo 'plugin_schema_info'"
    rename_table(:engine_schema_info, :plugin_schema_info) rescue nil
    if File.directory?("#{RAILS_ROOT}/public/engine_files")
      puts "In public/ => Renaming 'engine_files' to 'plugin_assets'"
      FileUtils.mv("#{RAILS_ROOT}/public/engine_files", "#{RAILS_ROOT}/public/plugin_assets")
    end
  end

  def self.down
    rename_table(:plugin_schema_info, :engine_schema_info) rescue nil
    if File.directory?("#{RAILS_ROOT}/public/plugin_assets")
      FileUtils.mv("#{RAILS_ROOT}/public/plugin_assets", "#{RAILS_ROOT}/public/engine_files")
    end
  end
end
