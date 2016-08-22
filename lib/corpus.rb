require_relative 'term_frequency'

Class Corpus
# Represents a group of text. Enables for example to perform
# some operations on a Document object while avec an eye on
# the other Documents (tf-idf for example)
  attr_accessor :documents, :idf
  def initialize()
    @documents = [] 
    @idf = TFHash.new()
  end

  def self.from_documents(array_of_docs)
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

  def update_idf
    unless @documents.length != 0
      raise ArgumentError, "There is no documents in the corpus"
    end
    first_one = true
    @documents.each do |doc|
      if first_one 
        @idf = doc.tfh
        first_one = false
      else
        self.idf.merge(doc.tfh)
      end
    end
  end
end
