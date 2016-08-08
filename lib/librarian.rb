#vim :e test/test_librarian/test_librarian.rb
# TODO: There is nothing here yet

require_relative "term_frequency"

class Librarian
# Control structure over a text datas (files, strings,
# arrays of words, database stored data etc...), giving access to and keeping track of
# various text semantic processings.
# Can be seen as the implementation of the text processing
# pipeline architecture

  def initialize()
  # Initialize an empty Librarian object
  end

  # Various functions to add some text data to the librarian.
  # In the end, all the data will be added as arrays.
  def add_file(filepath, name="")
  # Gives to the librarian a text file with empty metadata
  end
  def add_string(filepath, name="")
  # Gives to the librarian a string with empty metadata
  end
  def add_array(filepath, name="")
  # Gives to the librarian a word array with empty metadata
  end



end
