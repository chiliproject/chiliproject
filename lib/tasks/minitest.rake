require "rake/testtask"

Rake::TestTask.new(:minitest => "db:test:prepare") do |t|
  t.libs << "minitest"
  t.pattern = "minitest/**/*_test.rb"
end
