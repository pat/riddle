require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
  spec.pattern   = 'spec/**/*_spec.rb'
  spec.rcov      = true
end
