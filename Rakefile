require 'rake'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'riddle'

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Riddle - Ruby Sphinx Client'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run Riddle's specs"
Spec::Rake::SpecTask.new do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |t|
  t.libs << 'lib'
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
end

spec = Gem::Specification.new do |s|
  s.name              = "riddle"
  s.version           = Riddle::Version::GemVersion
  s.summary           = "API for Sphinx, written in and for Ruby."
  s.description       = "API for Sphinx, written in and for Ruby."
  s.author            = "Pat Allan"
  s.email             = "pat@freelancing-gods.com"
  s.homepage          = "http://riddle.freelancing-gods.com"
  s.has_rdoc          = true
  s.rdoc_options     << "--title" << "Riddle -- Ruby Sphinx Client" <<
                        "--main"  << "Riddle::Client" <<
                        "--line-numbers"
  s.rubyforge_project = "riddle"
  s.test_files        = FileList["spec/**/*_spec.rb"]
  s.files             = FileList[
    "lib/**/*.rb",
    "MIT-LICENCE",
    "README"
  ]
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc "Build gemspec file"
task :build do
  File.open('riddle.gemspec', 'w') { |f| f.write spec.to_ruby }
end