source 'http://rubygems.org'

gemspec

gem 'mysql2',     '0.3.20', :platform => :ruby
gem 'jdbc-mysql', '5.1.35', :platform => :jruby

%w[
  rspec
  rspec-expectations
  rspec-mocks
].each do |library|
  gem library, :git => "https://github.com/rspec/#{library}.git"
end

gem "rspec-core",
  :git    => "https://github.com/pat/rspec-core.git",
  :branch => "string-literals-2"
gem "rspec-support",
  :git    => "https://github.com/pat/rspec-support.git",
  :branch => "string-literals"
