require_relative 'term_frequency'

# Represent a unit of text. Many documents can form a corpus,
# another class

# A document can clean itself (tokenization, stop-word
# removal etc...) and yield various representations of itself
# like TF-IDF, ngrams, markov model etc...
class Document
  attr_accessor :stop_words, :source
  attr_reader :access

  # Constructors
  def initialize(name = nil)
    # Initializes an empty document, not very usefull
    @access = {}
    @access[name: name] if name
    @source = []
    @length = 0
    @stop_words_array_memory = [' ']
    @stop_words = / / # For example
  end

  # instantiate empty docs, and fill them with methods
  # :add_file, :add_string or :add_array
  def self.from_file(filepath, name = nil)
    obj = self.new(name)
    obj.add_file(filepath)
    obj
  end

  def self.from_string(string, name = nil)
    obj = self.new(name)
    obj.add_string(string)
    obj
  end

  def self.from_array(array, name = nil)
    obj = self.new(name)
    obj.add_array(array)
    obj
  end

  # Clears the document
  def reset
    @source = []
    @length = 0
    @access = {}
    
    # By default a document considers only a space as a stop
    # word
    @stop_words_array_memory = [' ']
    @stop_words = / / # Matches whitespace
  end

  # Number of words in the document
  def length
    @source.length
  end

  # Appends an array of words to the document
  def add_array(array, rebuild = Hash.new(true))
    raise ArgumentError, 'The argument needs to be an Array' unless array.is_a?(Array)

    array.each do |w|
      # When two stop words occur one next to the other in a
      # text, the resulting array contains an empty string.
      # As this happens quite often, I filter out the empty
      # strings out of the document.
      @source << w unless w == ''
    end

    build_tfh if @access[:tfh] && rebuild[:tfh]
    build_tfidf if @access[:tfidf] && rebuild[:tfidf]

    # I return the Document object to enable chaining
    self
  end

  def add_string(text, stop_regex = @stop_words, rebuild = Hash.new(true))
    raise ArgumentError, 'The argument needs to be an String' unless text.is_a?(String)

    # Splits the text on stop words (including spaces) and
    # then relies on the corresponding method for array
    self.add_array(text.split(stop_regex), rebuild)

    # I return the Document object to enable chaining
    self
  end

  def add_file(filepath, stop_regex = @stop_words, rebuild = Hash.new(true))
    raise ArgumentError, 'The argument needs to be a String' unless filepath.is_a?(String)

    File.foreach(filepath) do |line|
      # Extracts text from file and then relies on the
      # corresponding method for text
      self.add_string(line, stop_regex, Hash.new(false))
    end
    build_tfh if @access[:tfh] && rebuild[:tfh]
    build_tfidf if @access[:tfidf] && rebuild[:tfidf]

    # I return the Document object to enable chaining
    self
  rescue StandardError
    # Catches wrong filenames for example
    STDERR.puts "Failed to open '#{filepath}'"
    raise
  end
  # --- End of constructors ---

  # --- stop words ---
  # Stop words are words that get removed when analysing the
  # document
  # Defining the stop words
  def stop_words=(array)
    if array.is_a?(Array)
      # Stores the list of stop words and automatically
      # builds a corresponding regexp with update_stop_words
      @stop_words_array_memory = array
      @stop_words = self.update_stop_words
    elsif array.is_a?(Regexp)
      # No array of stop words means more liberty in the
      # choice of stop words but less flexibility in changing
      # them
      @stop_words_array_memory = nil
      @stop_words = array
    else
      raise ArgumentError, 'Skip words can only be built from regexp or array of words'
    end

    # Returns a boolean so that one can check if the
    # stop_words updating went well
    true
  end

  def add_stop_word(word)
    # To add a stop word, the stop words need to be defined
    # with an array. If only a Regexp is defined then is no
    # way to add a stop word to the current set of stop words
    raise NoMethodError, "Can't add stop word if stop word list was built from regexp. Try to build it from array of words" unless @stop_words_array_memory

    # Add the word and constructs a new regexp from the array
    # of stop words
    @stop_words_array_memory << word
    self.update_stop_words

    # Returns a boolean so that one can check if the
    # stop_words updating went well
    true
  end

  # Takes the stop word list and re-builds the regexp used to
  # spot them.
  def update_stop_words
    temp = []
    # Exhaustive list of characters that need to be escaped
    # in ruby regexps
    escape = '.|[](){}+\/?*^$'.split('')
    @stop_words_array_memory.each do |w|
      # Escapes the characters that need to be escaped in the
      # stop_words
      temp << (escape.include?(w) ? "\\#{w}" : w)
    end

    # The regexp describing the stop_words is built by
    # concatenating stop_words with |
    @stop_words = Regexp.new(temp.join('|'))
  end
  # --- end of stop word methods ---

  # --- TF-IDF methods ---
  # Builds the term frequency hash
  # cf term_frequency.rb
  def build_tfh
    @access[:tfh] = TFHash.from_array(@source)
  end

  def tfidf(words, idf)
    build_tfh unless @access[:tfh]
    words = [words] if words.is_a?(String)
    words.collect do |w|
      @access[:tfh][word].to_f * idf[word]
    end
  end

  def build_tfidf(idf)
    temp = idf.to_a.sort{ |e1, e2| e1[0] <=> e2[0] }
    temp.collect!{ |e| @access[:tfh][e[0]].to_f * e[1] }
    @access[:idf] = temp
    temp
  end
  # --- end of tfh methods ---

  # --- N-grams ---
  def ngrams(n)
    # Already implemented in core ruby for iterables with
    # each_cons.
    @source.each_cons(n).to_a
  end

  def unigrams
    ngrams(1)
  end

  def bigrams
    ngrams(2)
  end

  def trigrams
    ngrams(3)
  end
  # --- end of N-grams methods ---
end
