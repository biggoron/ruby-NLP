# TODO: There is nothing here yet
Class Document
# Represent a unit of text. Many documents can form a corpus,
# another class

  attr_accessor :length, :max, :skip_words, :source, :corpus
  # Constructors
  def initialize()

    # An empty document, not very usefull
    @length = 0

    # Tf
    @tf = nil

    # Unrelevant words, punctuation etc...
    @skip_words = ['', '.', ',', '/'] # For example
  end

  def self.from_file(filepath)
    obj = self.new
    obj.add_file(filepath)
    obj 
  end
  def self.from_string(string)
    obj = self.new
    obj.add_string(string)
    obj 
  end
  def self.from_array(array)
    obj = self.new
    obj.add_array(array)
    obj 
  end

  def add_array(array)
# # Merge an array of words in the Hash
#   raise ArgumentError, "The argument needs to be an Array" if array.class != Array
#   array.each do |word|
#     # TODO: test the skip words thing
#     next if @skip_words.include?(word)
#     @length += 1   if @tfh[word.to_s]  == 0
#     @max += 1      if @tfh[word.to_s]  == @max
#     @tfh[word.to_s] =  (@tfh[word.to_s] += 1)
#   end
#   self
  end

  # TODO: A rollback function to remove an array/string/file
  # from the hash

  def add_string(text)
# # Merge a string in the Hash
# # The regex should be an instance variable, that can be
# # constructed from array
#   raise ArgumentError, "The argument needs to be a string" if text.class != String
#   self.add_array(text.split(' '))
  end

  def add_file(filepath)
# # Merge a string in the Hash
#   raise ArgumentError, "The argument needs to be a string" if filepath.class != String
#   begin
#     File.foreach(filepath) { |line|  
#       self.add_string(line)
#     }
#   rescue Exception
#     STDERR.puts "Failed to open \"#{filepath}\""
#     raise
#   ensure
#   end
#   self
  end

  def tf=
     
  end

end
