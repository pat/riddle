source 'http://rubygems.org'

gemspec

gem 'mysql2',     '0.3.20', :platform => :ruby
gem 'jdbc-mysql', '5.1.35', :platform => :jruby

%w[
  rspec
  rspec-core
  rspec-expectations
  rspec-mocks
  rspec-support
].each do |library|
  gem library, :git => "https://github.com/rspec/#{library}.git"
end
