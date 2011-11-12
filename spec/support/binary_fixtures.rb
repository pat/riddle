module BinaryFixtures
  def self.build_fixtures(version = nil)
    return if ENV['TRAVIS']

    version ||= %w(0.9.9 1.10 2.0.1 2.1.0)
    Array(version).each do |version|
      FileUtils.mkdir_p "spec/fixtures/data/#{version}"
      `php -f spec/fixtures/data_generator.#{version}.php`
    end
  end

  def query_contents(key)
    path     = "spec/fixtures/data/#{Riddle.loaded_version}/#{key}.bin"
    contents = open(path) { |f| f.read }
    contents.respond_to?(:encoding) ?
      contents.force_encoding('ASCII-8BIT') : contents
  end
end
