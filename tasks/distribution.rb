YARD::Rake::YardocTask.new

Jeweler::Tasks.new do |gem|
  gem.name        = 'riddle'
  gem.summary     = 'An API for Sphinx, written in and for Ruby.'
  gem.description = 'A Ruby API and configuration helper for the Sphinx search service.'
  gem.email       = "pat@freelancing-gods.com"
  gem.homepage    = "http://freelancing-god.github.com/riddle/"
  gem.authors     = ["Pat Allan"]
  
  gem.files = FileList[
    'lib/**/*.rb',
    'LICENSE',
    'README.textile'
  ]
end

Jeweler::GemcutterTasks.new
