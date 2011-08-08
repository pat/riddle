YARD::Rake::YardocTask.new

Jeweler::Tasks.new do |gem|
  gem.name        = 'widdle'
  gem.version     = '0.1.0'
  gem.summary     = 'A modern ruby wrapper for SphinxQL'
  gem.description = 'A ruby SphinxQL wrapper and configuration helper for the Sphinx search service.'
  gem.email       = "tribalvibes@tribalvibes.com"
  gem.homepage    = "https://github.com/tribalvibes/widdle/"
  gem.authors     = ["tribalvibes"]
  
  gem.files = FileList[
    'lib/**/*.rb',
    'LICENSE',
    'README.textile'
  ]
end

Jeweler::GemcutterTasks.new
