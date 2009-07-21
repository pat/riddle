# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{riddle}
  s.version = "0.9.9.1785.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Allan"]
  s.date = %q{2009-07-21}
  s.description = %q{API for Sphinx, written in and for Ruby.}
  s.email = %q{pat@freelancing-gods.com}
  s.files = ["lib/riddle/client/filter.rb", "lib/riddle/client/message.rb", "lib/riddle/client/response.rb", "lib/riddle/client.rb", "lib/riddle/configuration/distributed_index.rb", "lib/riddle/configuration/index.rb", "lib/riddle/configuration/indexer.rb", "lib/riddle/configuration/remote_index.rb", "lib/riddle/configuration/searchd.rb", "lib/riddle/configuration/section.rb", "lib/riddle/configuration/source.rb", "lib/riddle/configuration/sql_source.rb", "lib/riddle/configuration/xml_source.rb", "lib/riddle/configuration.rb", "lib/riddle/controller.rb", "lib/riddle.rb", "lib/tabtab_definitions.rb", "MIT-LICENCE", "README", "spec/functional/excerpt_spec.rb", "spec/functional/keywords_spec.rb", "spec/functional/persistance_spec.rb", "spec/functional/search_spec.rb", "spec/functional/status_spec.rb", "spec/functional/update_spec.rb", "spec/unit/client_spec.rb", "spec/unit/configuration/distributed_index_spec.rb", "spec/unit/configuration/index_spec.rb", "spec/unit/configuration/indexer_spec.rb", "spec/unit/configuration/searchd_spec.rb", "spec/unit/configuration/source_spec.rb", "spec/unit/configuration/sql_source_spec.rb", "spec/unit/configuration/xml_source_spec.rb", "spec/unit/configuration_spec.rb", "spec/unit/filter_spec.rb", "spec/unit/message_spec.rb", "spec/unit/response_spec.rb", "spec/unit/riddle_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://riddle.freelancing-gods.com}
  s.rdoc_options = ["--title", "Riddle -- Ruby Sphinx Client", "--main", "Riddle::Client", "--line-numbers"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{riddle}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{API for Sphinx, written in and for Ruby.}
  s.test_files = ["spec/functional/excerpt_spec.rb", "spec/functional/keywords_spec.rb", "spec/functional/persistance_spec.rb", "spec/functional/search_spec.rb", "spec/functional/status_spec.rb", "spec/functional/update_spec.rb", "spec/unit/client_spec.rb", "spec/unit/configuration/distributed_index_spec.rb", "spec/unit/configuration/index_spec.rb", "spec/unit/configuration/indexer_spec.rb", "spec/unit/configuration/searchd_spec.rb", "spec/unit/configuration/source_spec.rb", "spec/unit/configuration/sql_source_spec.rb", "spec/unit/configuration/xml_source_spec.rb", "spec/unit/configuration_spec.rb", "spec/unit/filter_spec.rb", "spec/unit/message_spec.rb", "spec/unit/response_spec.rb", "spec/unit/riddle_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
