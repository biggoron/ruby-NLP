# encoding: utf-8

# Doesn't work yet

# A simplified markov chain implementation to model texts
class MarkovChain
  attr_accessor :nodes, :current_node

  # The text needs to be preprocessed into an array of words
  # or tokens.
  def initialize
    @nodes = {}
  end

  def add_node(word)
    raise ArgumentError, "A node with word: '#{word}' already exists!" if @nodes.key?(word.to_s)

    # Each node object is referenced by its corresponding
    # word. Indexing by string representation is efficient.
    @nodes[word.to_s] = Node.new(word)

    # Enables concatenation of functions by returning self
    self
  end

  def remove_node(word)
    raise ArgumentError, "No node with name: '#{word}'" unless @nodes.key?(word.to_s)

    @nodes[word.to_s] = nil

    self
  end

  def add_edge(source, dest, w)
    # Checks if both ends of the edge exist
    raise ArgumentError, 'Source node not found' unless @nodes.key?(source.to_s)
    raise ArgumentError, 'Destination node not found' unless @nodes.key?(dest.to_s)

    # An edge is caracterized by its destination and its weight
    @nodes[source.to_s].add_edge(dest, w)

    self
  end

  def normalize
    # Makes the sum of weight from every node sum up to 1
    @nodes.each do |_, n|
      n.normalize
    end
  end

  def normalize_node(w)
    raise ArgumentError, 'Node not found' unless @nodes.key?[w.to_s]
    @nodes[w.to_s].normalize
  end
end

# A node contains a word and a list of the following possible nodes.
# This class is used for the Markov chain text model
class Node
  attr_accessor :edges
  attr_reader   :words

  def initialize(words)
    raise ArgumentError, "The model length doesn't match the number of words given"  if model_length != words.length
    raise ArgumentError, 'First argument needs to be a string or an array'           unless words.is_a?(String) or words.is_a?(Array)
    raise ArgumentError, "Can't handle length-1 array, please use string"            if words.is_a?(Array) and words.length == 1

    @words = words
    @model_length = words.is_a?(String) ? 1 : words.length
    @edges = {}
  end

  # An edge consists of a destination node and a probabilistic weight
  def add_edge(dest, w)
    # Checks if the edge already exists
    raise ArgumentError, 'Edge is already connected' if @edges.key?(dest.to_s)
    raise ArgumentError, "First argument of add_edge needs to be a Node. Failed to link #{@words} to destination #{dest}" unless dest.is_a?(Node)

    @edges[dest.to_s] = w

    self
  end

  def same_as?(another_node)
    raise ArgumentError, "Same_as takes a Node as an Argument" unless another_node.is_a?(Node)

    # First check if the node has the same kind of information
    return false if another_node.model_length != @model_length
    # If it is a single word, compare simply
    if self.words.is_a?(String)
      return true if self.words == another_node.words
    else # Else compare each element of the array of words
      self.words.each_with_index do |w, i|
        return false if w != another_node.words[i]
      end
    end
    # If the program get here, the two words array have same length and same items
    return true
  end

  def normalize
    # Makes the weights of the edges add up to 1
    sum = 0
    @edges.each do |_, w|
      sum += w
    end

    @edges.each do |e, w|
      @edges[e] = w / sum.to_f
    end
  end

  def normalized?
    # Checks if the weights of the edges add up to 1
    sum = 0.0
    @edges.each do |_, w|
      sum += w
    end

    sum > 0.999999999
  end

  def next
    # Node's transition probabilities need to sum up to 1.
    raise StandartError, "The transition probabilities of the node #{@words} need to sum up to one" unless self.normalized?

    prob_hash = {}
    self.edges.inject(0) do |total, (n, w)|
      # Divides the segment from 0 to 1 according to the
      # transition probability
      prob_hash[total + w] = n
      total + w
    end

    # Picks a random number between 0 and 1
    rand_number = rand
    node = nil
    value = 2 # Just needs to be greater than 1
    prob_hash.each do |p, n|
      # iterates to find which is the node corresponding to
      # the picked number.
      if p <= value && rand_number < p
        node = n
        value = p
      end
    end

    node
  end
end
