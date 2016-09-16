# encoding: utf-8

require_relative 'term_frequency'

# Represents a group of text. Enables for example to perform
# some operations on a Document object while avec an eye on
# the other Documents (tf-idf for example)
class Corpus
  attr_reader :documents, :access

  # --- Constructors ---
  def initialize(name = nil)
    # Initial Corpus is empty
    @documents = []
    @access    = {}
    @access[name: name] if name
  end

  # Constructs a corpus of documents from an array of
  # documents
  def self.from_documents(array_of_docs)
    raise ArgumentError, "Can't build a corpus from 0 doc" if array_of_docs.empty?

    obj = self.new
    @documents << array_of_docs if docs.is_a?(Document) 
    @documents.concat(array_of_docs) if docs.is_a?(Array)
    obj
  end
  # --- End of constructors ---

  # Setters
  def add_documents(docs, rebuild = Hash.new(true))
    @documents << docs if docs.is_a?(Document) 
    @documents.concat(docs) if docs.is_a?(Array)
    rebuild_access(rebuild)
  end
  # -----

  def rebuild_access(rebuild = Hash.new(true))
    build_vocabulary if rebuild[:voc] && @access[:voc]
    build_idf if rebuild[:idf] && @access[:idf]
    build_knn if rebuild[:knn] && @access[:knn]
  end

  # Knn
  def build_knn
    values = @documents.collect{ |d| d.build_tfidf(@access[:idf]) }
    require './lib/knn.rb'
    @access[:knn] = Knn.new(values)
  end

  def knn_get_k(document, k)
    build_knn unless @access[:knn]
    @access[:knn].get_k(d.build_tfidf(@access[:idf]), k)
  end
    
  def knn_get_d(document, d)
    build_knn unless @access[:knn]
    @access[:knn].get_d(d.build_tfidf(@access[:idf]), d)
  end
  # ------

  # --- TF-IDF ---
  def idf(word)
    build_vocabulary unless @access[:voc]
    raise ArgumentError, "'#{word}' doesn't appear in the corpus" unless @access[:voc].include?(word)
    raise ArgumentError, 'There is no documents in the corpus' if @documents.empty?

    count = 0
    num = @documents.length
    @document.each do |doc|
      count += 1 if doc.source.include?(word)
    end

    Math.log(num.to_f / count.to_f)
  end

  def build_idf
    build_vocabulary unless @access[:vocabulary]
    temp = {}
    @access[:vocabulary].each{ |v| temp[v] = idf(v) }
    @access[:idf] = temp
  end
  # --- end of TF-IDF ---

  def build_vocabulary
    @access[:vocabulary] = []
    # merges without duplicates
    @documents.each{ |doc| @access[:vocabulary] | doc.source }
  end
end
