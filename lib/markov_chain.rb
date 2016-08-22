class MarkovChain
# A simplified markov chain implementation to model texts
  attr_accessor :nodes, :current_node

  def initialize(array)
  # The text needs to be preprocessed into an array of words
  # or tokens.
    @nodes = {}
    @current_node = nil
  end
# def generate(n, separator = ' ')
# # TODO: adapt to a multiword node
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
  def add_node(word)
  # TODO: adapt to a multiword node
    if @nodes.key?(word)
      # Don't add an existing word
      raise ArgumentError, "A node with word: '#{word}' already exists!"
      # Enables concatenation of functions by returning self
      return self
    else
      # Each node object is referenced by its corresponding
      # word. Indexing is efficient.
      @nodes[word] = (Node.new(word))
      return self
    end
  end
  def remove_node(word)
  # TODO: adapt to a multiword node
    if @nodes.key?[word]
      # Checks if the node exists
      @nodes[word] = nil
      return self
    else
      raise ArgumentError, "No node with name: '#{word}'"
      return self
    end
  end
  def add_edge(source, dest, w)
  # TODO: adapt to a multiword node
    unless @nodes.key?(source) and @nodes.key?(dest)
      # Checks if both ends of the edge exist
      raise ArgumentError, "either the source or destination node was not found"
      return self
    end
    # An edge is caracterized by its destination and its
    # weight
    @nodes[source].add_edge(dest, w)
    return self
  end
  def normalize
  # TODO: adapt to a multiword node
    # Makes the sum of weight from every node sum up to 1
    @nodes.each do |w, n|
      n.normalize
    end
  end
  def normalize_node(w)
  # TODO: adapt to a multiword node
    unless @nodes.key?[w]
      raise ArgumentError, "Node not found"
      return self
    end
    @nodes[w].normalize
  end

  def next
  # TODO: Move to Node and adapt to a multiword node
    unless @current_node.normalized?
      # Node's transition probabilities need to sum up to 1.
      puts "node is not normalized"
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
      if p <= value and rand_number < p
        node = n
        value = p 
      end
    end
    @current_node = @nodes[node]
    return self
  end
end

class Node
  # A node contains a word and a list of the following
  # possible nodes.
  # This class is used for the Markov chain text model
  attr_accessor :model_length, :words, :edges
  def initialize(words, model_length = words.length)
    @words = words
    if model_length != words.length
      raise ArgumentError, "The model length doesn't match the number of words given"
    end
    @edges = {}
  end

  def add_edge(dest, w)
    # An edge consists of a destination node and a
    # probabilistic weight
    if @edges.key?(dest)
      # Checks if the edge already exists
      raise ArgumentError, "Edge is already connected"
      return false
    elsif not dest.is_a? Node
      raise ArgumentError, "The first argument of add_edge
      needs to be a Node. Failed to link #{@words} to
      destination #{dest}"
      return false
    else
      @edges[dest] = w
      return self
    end
  end

  def normalize()
    # Makes the weights of the edges add up to 1
    sum = 0
    @edges.each do |e, w|
      sum += w
    end
    @edges.each do |e, w|
      @edges[e] = w / (sum.to_f)
    end
  end

  def normalized?()
    # Checks if the weights of the edges add up to 1
    sum = 0.0
    @edges.each do |e, w|
      sum += w
    end
    sum > 0.999999999
  end

  def next
    unless self.normalized?
      # Node's transition probabilities need to sum up to 1.
      raise StandartError, "The transition probabilities of the node #{@words} need to sum up to one"
      return self
    end
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
      if p <= value and rand_number < p
        node = n
        value = p 
      end
    end
    return node
  end
end

