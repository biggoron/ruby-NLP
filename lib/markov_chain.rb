# encoding: utf-8

# Doesn't work yet

# A simplified markov chain implementation to model texts
class MarkovChain
  attr_accessor :nodes, :current_node

  # The text needs to be preprocessed into an array of words
  # or tokens.
  def initialize
    @nodes = {}
    @current_node = nil
  end

  # # TODO: adapt to a multiword node
  # def generate(n, separator = ' ')
  #     random_word = @nodes.keys.sample
  #     current_node = @nodes[random_word]
  #   end
  #   string = []
  #   n.times do
  #     # builds a string by getting to the next node and
  #     # appending the corresponding word, n times
  #     # recursively.
  #     string << current_node.word
  #     current_node.next
  #   end
  #
  #   # readable format. By default words are concatenated with
  #   # spaces
  #   return string.join(separator)
  # end

  # TODO: adapt to a multiword node
  def add_node(word)
    raise ArgumentError, "A node with word: '#{word}' already exists!" if @nodes.key?(word)

    # Each node object is referenced by its corresponding
    # word. Indexing is efficient.
    @nodes[word] = Node.new(word)

    # Enables concatenation of functions by returning self
    self
  end

  # TODO: adapt to a multiword node
  def remove_node(word)
    raise ArgumentError, "No node with name: '#{word}'" unless @nodes.key?[word]

    @nodes[word] = nil

    self
  end

  # TODO: adapt to a multiword node
  def add_edge(source, dest, w)
    # Checks if both ends of the edge exist
    raise ArgumentError, 'Source node not found' unless @nodes.key?(source)
    raise ArgumentError, 'Destination node not found' unless @nodes.key?(dest)

    # An edge is caracterized by its destination and its weight
    @nodes[source].add_edge(dest, w)

    self
  end

  # TODO: adapt to a multiword node
  def normalize
    # Makes the sum of weight from every node sum up to 1
    @nodes.each do |_, n|
      n.normalize
    end
  end

  # TODO: adapt to a multiword node
  def normalize_node(w)
    raise ArgumentError, 'Node not found' unless @nodes.key?[w]

    @nodes[w].normalize
  end

  # TODO: Move to Node and adapt to a multiword node
  def next
    unless @current_node.normalized?
      # Node's transition probabilities need to sum up to 1.
      puts 'node is not normalized'
      return self
    end
    prob_hash = {}
    @current_node.edges.inject(0) do |total, (n, w)|
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
    @current_node = @nodes[node]
    self
  end
end

# A node contains a word and a list of the following possible nodes.
# This class is used for the Markov chain text model
class Node
  attr_accessor :model_length, :words, :edges

  def initialize(words, model_length = words.length)
    raise ArgumentError, "The model length doesn't match the number of words given" if model_length != words.length

    @words = words
    @edges = {}
  end

  # An edge consists of a destination node and a probabilistic weight
  def add_edge(dest, w)
    # Checks if the edge already exists
    raise ArgumentError, 'Edge is already connected' if @edges.key?(dest)
    raise ArgumentError, "The first argument of add_edge needs to be a Node. Failed to link #{@words} to destination #{dest}" unless dest.is_a?(Node)

    @edges[dest] = w

    self
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
