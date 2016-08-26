require_relative 'term_frequency'

class Document
# Represent a unit of text. Many documents can form a corpus,
# another class

# A document can clean itself (tokenization, stop-word 
# removal etc...) and yield various representations of itself 
# like TF-IDF, ngrams, markov model etc...

  attr_accessor :stop_words, :source, :tfh, :corpus

  # Constructors
  def initialize()
    # Initializes an empty document, not very usefull
    @source = []

    @length = 0

    @tfh = TFHash.new()

    @stop_words_array_memory = [" "]
    @stop_words = / / # For example
  end

  # instantiate empty docs, and fill them with methods
  # :add_file, :add_string or :add_array
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
  # Clears the document
    @source = []

    @length = 0

    @tfh = TFHash.new()

    # By default a document considers only a space as a stop
    # word
    @stop_words_array_memory = [" "]
    @stop_words = / / # Matches whitespace
  end

  def length
  # Number of words in the document
    @source.length
  end

  def add_array(array)
  # Appends an array of words to the document
    if not (array.is_a? Array)
      raise ArgumentError, "The argument needs to be an Array"
    end
    
    array.each do |w|
      # When two stop words occur one next to the other in a
      # text, the resulting array contains an empty string.
      # As this happens quite often, I filter out the empty
      # strings out of the document.
      @source << w unless w == ''
    end

    self.update_tfh

    # I return the Document object to enable chaining
    self
  end

  def add_string(text, stop_regex = @stop_words)
    if not text.is_a? String
      raise ArgumentError, "The argument needs to be an String"
    end
      
    # Splits the text on stop words (including spaces) and
    # then relies on the corresponding method for array 
    self.add_array(text.split(stop_regex))

    # I return the Document object to enable chaining
    self
  end

  def add_file(filepath, stop_regex = @stop_words)
    if not filepath.is_a? String
      raise ArgumentError, "The argument needs to be an String"
    end

    begin
      File.foreach(filepath) { |line|  
        # Extracts text from file and then relies on the
        # corresponding method for text
        self.add_string(line, stop_regex)
      }
    rescue Exception
      # Catches wrong filenames for example
      STDERR.puts "Failed to open \"#{filepath}\""
      raise
    ensure
    end

    # I return the Document object to enable chaining
    self
  end
  # --- End of constructors --- 

  # --- Corpus methods ---
  # being inserted in a corpus is necessary to perform some
  # processing like IDF
    
  def has_corpus?
    not @corpus.nil?
  end

  def corpus= (corpus)
    @corpus = corpus
  end

  def corpus
    @corpus
  end
  # --- end of corpus methods ---

  # --- stop words ---
  # Stop words are words that get removed when analysing the
  # document
    
  def stop_words= (array)
  # Defining the stop words
    if array.is_a? Array
      # Stores the list of stop words and automatically
      # builds a corresponding regexp with update_stop_words
      @stop_words_array_memory = array
      @stop_words = self.update_stop_words
    elsif array.is_a? Regexp
      # No array of stop words means more liberty in the
      # choice of stop words but less flexibility in changing
      # them
      @stop_words_array_memory = nil
      @stop_words = array
    else
      raise ArgumentError.new("Skip words can be built only from regexp or array of words")
      return false
    end

    # Returns a boolean so that one can check if the
    # stop_words updating went well
    return true
  end

  def add_stop_word(word)
    # To add a stop word, the stop words need to be defined
    # with an array. If only a Regexp is defined then is no
    # way to add a stop word to the current set of stop words
    unless @stop_words_array_memory    
      # The array of stop words needs to be defined
      raise NoMethodError.new("Can't add stop word if stop word list was built from regexp. Try to build it from array of words.")

    # Returns a boolean so that one can check if the
    # stop_words updating went well
      return false
    end
    
    # Add the word and constructs a new regexp from the array
    # of stop words
    @stop_words_array_memory << word
    self.update_stop_words

    # Returns a boolean so that one can check if the
    # stop_words updating went well
    return true
  end

  def update_stop_words
  # Takes the stop word list and re-builds the regexp used to
  # spot them.
    temp = []
    # Exhaustive list of characters that need to be escaped
    # in ruby regexps
    escape = '.|[](){}+\/?*^$'.split('')
    @stop_words_array_memory.each do |w|
      # Escapes the characters that need to be escaped in the
      # stop_words
      w = "\\" + w if escape.include?(w)
      temp << w
    end
    # The regexp describing the stop_words is built by
    # concatenating stop_words with |
    @stop_words = Regexp.new(temp.join('|'))
  end
  # --- end of stop word methods ---


  # --- TF-IDF methods ---
  def update_tfh
  # Builds the term frequency hash
  # cf term_frequency.rb
    @tfh = TFHash.from_array(@source)
  end
  
  def tfidf(word)
    raise(NoMethodError, "Needs a corpus to compute TFIDF") unless self.has_corpus?
    self.update_tfh
    @corpus.update_idf!
    return @tfh[word].to_f * @corpus.idf.call(word)
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
