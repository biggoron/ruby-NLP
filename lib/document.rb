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

    # Unrelevant words, punctuation etc...
    @skip_words_array_memory = ['.', ' ', ',', '/']
    @skip_words = /\.| |,|\/|\n/ # For example
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

  def add_array(array, skip_regex=@skip_regex)
    if array.class.name != "Array"
      raise ArgumentError, "The argument needs to be an Array"
    end
    array = array.join(' ').split(skip_regex)
    array.each do |w|
      next if w == ''
      @source << w
      @length += 1
    end
    @tfh.add_array(array)
    self
  end

  def add_string(text, skip_regex = @skip_regex)
    if text.class.name != "String"
      raise ArgumentError, "The argument needs to be an String"
    end
    self.add_array(text.split(skip_regex))
  end

  def add_file(filepath, skip_regex = @skip_regex)
    if filepath.class.name != "String"
      raise ArgumentError, "The argument needs to be an String"
    end
    begin
      File.foreach(filepath) { |line|  
        self.add_string(line, skip_regex)
      }
    rescue Exception
      STDERR.puts "Failed to open \"#{filepath}\""
      raise
    ensure
    end
    self
  end

  def skip_words= (array)
    if array.class.name == "Array"
      @skip_words_array_memory = array
      @skip_words = regexify(array)
    elsif array.class.name = "Regexp"
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
      raise NoMethodError.new("Can't add skip word if skip word list was built from regexp. Try to build it from array of words.")
      return false
    end
    @skip_words_array_memory << word

    self.update_skip_words

    return true
  end

  

private
  def update_skip_words
    temp = []
    escape = ['.', '/', '*', '^', '$'] # TODO: needs to be more exhaustive
    @skip_words_array_memory.each do |w|
      w = '\\' + w if escape.include?(w)
      temp << w
    end
    @skip_words = Regexp.new(temp.join('|'))
  end
end
