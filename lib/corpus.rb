require_relative 'term_frequency'

Class Corpus
# Represents a group of text. Enables for example to perform
# some operations on a Document object while avec an eye on
# the other Documents (tf-idf for example)

  attr_accessor :documents, :idf

  # --- Constructors ---
  def initialize()
    # Initial Corpus is empty
    @documents = [] 
    self.update_idf!
  end

  def self.from_documents(array_of_docs)
  # Constructs a corpus of documents from an array of
  # documents
    unless array_of_docs.length != 0
      raise ArgumentError, "Can't build a corpus from 0 docs"
    end
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
    return obj
  end
  # --- End of constructors ---

  # --- TF-IDF ---
  def update_idf!
    self.error_if_no_doc!

    num = @documents.length

    idf = -> (word) do
      raise (ArgumentError, "*#{word}* doesn't appear in the
      corpus") unless @vocabulary.include? word
      count = 0
      @document.each do |doc|
      count += 1 if doc.source.include? word
      Math.log(num.to_f / count.to_f)
    end

    @idf = idf
  end
  # --- end of TF-IDF ---

  def update_vocabulary!
    self.error_if_no_doc!
    @vocabulary = []
    @documents.each do |doc|
      @vocabulary << doc.source
      @vocabulary.uniq!
    end
    self
  end

private
  def error_if_no_doc!
    raise ArgumentError, "There is no documents in the corpus" unless @documents.length != 0
  end
end
