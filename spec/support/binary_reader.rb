module BinaryReader
  def query_contents(key)
    contents = open("spec/fixtures/data/#{key.to_s}.bin") { |f| f.read }
    contents.respond_to?(:encoding) ?
      contents.force_encoding('ASCII-8BIT') : contents
  end
end
