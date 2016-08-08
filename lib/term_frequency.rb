#vim :e test/test_term_frequency/test_term_frequency.rb

class TFHash
# @tfh is the term-frequency hash, accessed with []
# @length and @max are the number of unique words and maximum
# frequency
  # some aliases:
  attr_accessor :length, :max, :skip_words
  # Constructors
  # a term-frequency hash can be constructed with
  # self.from_file
  # self.from_array
  # self.from_string
  #
  # Every constructor channels the data throught
  # file > string > array and ultimatly add_array is called
  def initialize()
    @length = 0
    @max = 0
    # The default frequency is 0
    @tfh = Hash.new(0)
    # Unrelevant words, punctuation etc...
    @skip_words = ['', '.', ',', '/', ' ', '\n']
    @skip_words_r = /\n|\.|,|\/| /
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
    
  # Getters and setters
  def [](term)
    # Access the frequency hash like any other hash
    # However, the hash being internal, usual operations on
    # hash won't work. To modify the hash, you should go
    # throught the instance method: add_array, add_string,
    # add_file.
    # TODO: test the block part
    if block_given?
      # Accepts a bloc to process the frequency, passing it
      # the raw frequency and the max frequency
      yield @tfh[term], @max
    else
      @tfh[term]
    end
  end

  def exists?(term)
    # Binary frequency
    #TODO: test
    return @tfh[term] != 0
  end

  def log_frequency(term)
    # TODO: test
    # Normalize so that a 0 frequency matches with a 0 log
    # frequency
    return log(@tfh[term] + 1)
  end

  def knorm_frequency(term, k=0.5)
    # TODO: test
    return k + k*(@tfh[term] / @max.to_f)
  end

  def add_array(array)
  # Merge an array of words in the Hash
    raise ArgumentError, "The argument needs to be an Array" if array.class != Array
    array.each do |word|
      # TODO: test the skip words thing
      next if @skip_words.include?(word)
      @length += 1   if @tfh[word.to_s]  == 0
      @max += 1      if @tfh[word.to_s]  == @max
      @tfh[word.to_s] =  (@tfh[word.to_s] += 1)
    end
    self
  end

  # TODO: A rollback function to remove an array/string/file
  # from the hash

  def add_string(text)
  # Merge a string in the Hash
  # The regex should be an instance variable, that can be
  # constructed from array
    raise ArgumentError, "The argument needs to be a string" if text.class != String
    self.add_array(text.split(@skip_words_r))
  end

  def add_file(filepath)
  # Merge a string in the Hash
    raise ArgumentError, "The argument needs to be a string" if filepath.class != String
    begin
      File.foreach(filepath) { |line|  
        self.add_string(line)
      }
    rescue Exception
      STDERR.puts "Failed to open \"#{filepath}\""
      raise
    ensure
    end
    self
  end

  def reset
  # Resetting the hash
    @tfh = Hash.new(0)
    @length = 0
    @max = 0
  end
end
