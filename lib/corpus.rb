# encoding: utf-8

require_relative 'term_frequency'

# Represents a group of text. Enables for example to perform
# some operations on a Document object while avec an eye on
# the other Documents (tf-idf for example)
class Corpus
  attr_accessor :documents, :idf

  # --- Constructors ---
  def initialize
    # Initial Corpus is empty
    @documents = []

    self.update_idf!
  end

  # Constructs a corpus of documents from an array of
  # documents
  def self.from_documents(array_of_docs)
    raise ArgumentError, "Can't build a corpus from 0 doc" if array_of_docs.empty?

    obj = self.new
    first_one = true
    array_of_docs.each do |doc|
      if first_one
        @idf = doc.tfh
        @documents << doc
        first_one = false
      else
        self.idf.merge(doc.tfh)
      end
    end

    obj
  end
  # --- End of constructors ---

  # --- TF-IDF ---
  def update_idf!
    raise ArgumentError, 'There is no documents in the corpus' if @documents.empty?

    num = @documents.length

    idf = lambda word do
      raise ArgumentError, "'#{word}' doesn't appear in the corpus" unless @vocabulary.include?(word)

      count = 0
      @document.each do |doc|
        count += 1 if doc.source.include?(word)
      end

      Math.log(num.to_f / count.to_f)
    end

    @idf = idf
  end
  # --- end of TF-IDF ---

  def update_vocabulary!
    raise ArgumentError, 'There is no documents in the corpus' if @documents.empty?

    @vocabulary = []
    @documents.each do |doc|
      @vocabulary << doc.source
      @vocabulary.uniq!
    end

    self
  end
end
