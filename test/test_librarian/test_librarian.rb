#vim :e lib/librarian.rb
#vim :!rake test:librarian 
#vim :vsp log/bash_output.txt
require 'minitest/autorun'
require './lib/librarian'

class TestLibrarian < Minitest::Test
  def setup
    @my_librarian = Librarian.new()
  end

  def test_new_librarian_is_librarian_type
    assert_equal Librarian, @my_librarian.class
  end
end
