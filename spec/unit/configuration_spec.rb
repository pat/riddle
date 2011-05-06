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
    
    config.indexes << index
    generated_conf = config.render
    
    generated_conf.should match(/index index1/)
    generated_conf.should match(/source src1/)
    generated_conf.should match(/indexer/)
    generated_conf.should match(/searchd/)
  end
end