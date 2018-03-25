# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Parsing" do
  it "handles invalid configuration files" do
    Riddle::Configuration.parse!(<<-DOC)
latex_documents = [
  #
]
    DOC
  end
end
