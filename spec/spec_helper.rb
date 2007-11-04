require 'riddle'

Spec::Runner.configure do |config|
  #
end

def query_contents(key)
  open("spec/fixtures/data/#{key.to_s}.bin") { |f| f.read }
end