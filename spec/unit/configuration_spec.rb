# frozen_string_literal: true

require 'spec_helper'

describe Riddle::Configuration do
  it "should render all given indexes and sources, plus the indexer and search sections" do
    config = Riddle::Configuration.new

    config.searchd.port = 3312
    config.searchd.pid_file = "file.pid"

    source = Riddle::Configuration::XMLSource.new("src1", "xmlpipe")
    source.xmlpipe_command = "ls /dev/null"

    index = Riddle::Configuration::Index.new("index1")
    index.path = "/path/to/index1"
    index.sources << source

    config.indices << index
    generated_conf = config.render

    expect(generated_conf).to match(/index index1/)
    expect(generated_conf).to match(/source src1/)
    expect(generated_conf).to match(/indexer/)
    expect(generated_conf).to match(/searchd/)
  end
end