require 'term_frequency'

RSpec.describe TFHash, "#length" do
  context "Without any input" do
    it "has length 0" do
      my_TFH = TFHash.new()
      expect(my_TFH.length).to eq 0
    end
  end
end
