# TODO: There is nothing here yet
require_relative 'term_frequency'

class Document
# Represent a unit of text. Many documents can form a corpus,
# another class

  # @length is the number of words
  attr_accessor :length, :skip_words, :source, :tfh
  # Constructors
  def initialize()
    # Initializes an empty document, not very usefull
    @source = []

    @length = 0

    @tfh = TFHash.new()

    @skip_words_array_memory = [" "]
    @skip_words = / / # For example
  end

  # Constructors
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

  def reset
    @source = []

    @length = 0

    @tfh = TFHash.new()

    # TODO: clever defaults
    @skip_words_array_memory = [" "]
    @skip_words = / / # Matches whitespace
  end

  def length=
    @source.length
  end

  def add_array(array)
    if array.class.name != "Array"
      raise ArgumentError, "The argument needs to be an Array"
    end
    
    array.each do |w|
      @source << w unless w == ''
    end

    self.update_tfh
    self
  end

  def add_string(text, skip_regex = @skip_words)
    if text.class.name != "String"
      raise ArgumentError, "The argument needs to be an String"
    end
      
    # Relies on the array constructor
    self.add_array(text.split(skip_regex))
  end

  def add_file(filepath, skip_regex = @skip_words)
    if filepath.class.name != "String"
      raise ArgumentError, "The argument needs to be an String"
    end
    begin
      File.foreach(filepath) { |line|  
        self.add_string(line, skip_regex)
      }
    rescue Exception
      # Catches wrong filenames for example
      STDERR.puts "Failed to open \"#{filepath}\""
      raise
    ensure
    end
    self
  end

  def skip_words= (array)
    if array.class.name == "Array"
      # Stores the list of skip words and automatically
      # builds a corresponding regexp with update_skip_words
      @skip_words_array_memory = array
      @skip_words = self.update_skip_words
    elsif array.class.name == "Regexp"
      # No array of skip words means more liberty in the
      # choice of skip words but less flexibility in changing
      # them
      @skip_words_array_memory = nil
      @skip_words = array
    else
      raise ArgumentError.new("Skip words can be built only from regexp or array of words")
      return false
    end
    return true
  end

  def add_skip_word(word)
    unless @skip_words_array_memory    
      # The array of skip words needs to be defined
      raise NoMethodError.new("Can't add skip word if skip word list was built from regexp. Try to build it from array of words.")
      return false
    end
    
    # Add the word and construct a new regexp
    @skip_words_array_memory << word
    self.update_skip_words

    return true
  end

  def update_tfh

    # Builds the TF
    @tfh = TFHash.from_array(@source)
  end

  def update_skip_words
    temp = []
    escape = ['.', '/', '*', '^', '$'] # TODO: needs to be more exhaustive
    @skip_words_array_memory.each do |w|
      w = "\\" + w if escape.include?(w)
      temp << w
    end
    @skip_words = Regexp.new(temp.join('|'))
  end
end
