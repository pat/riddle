# frozen_string_literal: true

module BinaryFixtures
  def query_contents(key)
    path     = "spec/fixtures/data/#{Riddle.loaded_version}/#{key}.bin"
    contents = open(path) { |f| f.read }
    contents.respond_to?(:encoding) ?
      contents.force_encoding('ASCII-8BIT') : contents
  end
end
