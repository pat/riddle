Gem::Specification.new do |s|
  s.name              = "riddle"
  s.version           = "0.9.8.1231.1"
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
  s.test_files        = ["spec/functional/excerpt_spec.rb", "spec/functional/keywords_spec.rb", "spec/functional/search_spec.rb", "spec/functional/update_spec.rb", "spec/unit/client_spec.rb", "spec/unit/filter_spec.rb", "spec/unit/message_spec.rb", "spec/unit/response_spec.rb"]
  s.files             = ["lib/riddle/client/filter.rb", "lib/riddle/client/message.rb", "lib/riddle/client/response.rb", "lib/riddle/client.rb", "lib/riddle.rb", "MIT-LICENCE", "README"]
end