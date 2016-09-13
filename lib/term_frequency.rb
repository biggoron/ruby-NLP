# encoding: utf-8

# @tfh is the term-frequency hash, accessed with []
# @length and @max are the number of unique words and maximum
# frequency
class TFHash
  attr_accessor :length, :max, :skip_words

  # Constructors
  # a term-frequency hash can be constructed with
  # self.from_file
  # self.from_array
  # self.from_string
  #
  # Every constructor channels the data throught
  # file > string > array and ultimatly add_array is called
  def initialize(skip_words = [' ', ',', '.', "\n", "\r"])
    @length = 0
    @max = 0

    # The default frequency is 0
    @tfh = Hash.new(0)

    # Unrelevant words, punctuation etc...
    @skip_words = skip_words
    @skip_words_r = regexpify(@skip_words)
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
    @tfh[term]
  end

  def words
    @tfh.keys
  end

  # Binary frequency
  def exists?(term)
    ! (@tfh[term]).zero?
  end

  # Normalize so that a 0 frequency matches with a 0 log
  # frequency
  def log_frequency(term)
    Math.log(@tfh[term] + 1)
  end

  def knorm_frequency(term, k = 0.5)
    k + k * (@tfh[term] / @max.to_f)
  end

  # Merge an array of words in the Hash
  def add_array(array)
    raise ArgumentError, 'The argument needs to be an Array' unless array.is_a?(Array)

    array.each do |word|
      next if word.strip.empty?

      @length += 1 if (@tfh[word.to_s]).zero?
      @max += 1 if @tfh[word.to_s] == @max

      @tfh[word.to_s] += 1
    end
    self
  end

  # Merge a string in the Hash
  # The regex should be an instance variable, that can be
  # constructed from array
  def add_string(text)
    raise ArgumentError, 'The argument needs to be a String' unless text.is_a?(String)

    self.add_array(text.split(@skip_words_r))
  end

  # Merge a string in the Hash
  def add_file(filepath)
    raise ArgumentError, 'The argument needs to be a String' unless filepath.is_a?(String)

    File.foreach(filepath) do |line|
      self.add_string(line)
    end

    self
  rescue StandardError
    STDERR.puts "Failed to open \"#{filepath}\""
    raise
  end

  # Resetting the hash
  def reset
    @tfh = Hash.new(0)
    @length = 0
    @max = 0
  end

  private

  def regexpify(array)
    # TODO: test

    # Transforms the array of words into a regexp matching
    # any of the words
    temp = []
    escape = '.|[](){}+\/?*^$'.split('')
    return Regexp.new(' ') if array.empty?

    array.each do |w|
      temp << (escape.include?(w) ? "\\#{w}" : w)
    end

    Regexp.new(temp.join('|'))
  end

  def merge(other_tfh)
    # TODO: test

    array_to_add = []
    other_tfh.tfh.each do |token, count|
      count.times do
        array_to_add << token
      end
    end

    self.add_array(array_to_add)
  end
end
