# encoding: utf-8

class BPlusTree
  attr_reader :root, :branching_factor

  class BPlusNode
    # Represents a node in the tree. There is two kinds of
    # nodes, usual nodes and leaves, which behave slightly
    # differently.
    # A Node has keys, indexing some children. For the leaves
    # the children are the values stored in the tree.
    attr_reader :keys, :children, :parent, :branching_factor

    def initialize(b, keys = [], children = [], parent = nil)
      # The branching factor is the number of children
      # allowed per node.
      @branching_factor = b
      @keys = keys
      @children = children
      @parent = parent
      @max_branching = b - 1
    end

    def leaf?
      # A leaf inherits from the node object and, among other
      # things overrides :leaf? to true
      false
    end

    def root?
      # A node is root <=> it has no parent
      !parent
    end

    def to_s
      # A usual node is represented as the sequence of its
      # keys. A leaf node shows the values stored with each
      # key and this method is overriden in BPlusLeaf.
      unless @keys.empty?
        '[ ' + @keys.join(' | ') + ' ]'
      else
        []
      end
    end

    def insert(k, v)
      # Top down approach, the insert request trickles down
      # the Tree from the root to the relevant leaf
      #
      # Get the index of the children which range includes k
      index = get_index(k)
      # Make the child insert the entry
      @children[index].insert(k, v)
      # The process of handing down the same request to the
      # relevant child stops when the request arrives to a
      # leaf. cf. the implementation of :insert in the Leaf
      # object
    end

    def add_entry(k, v)
      # Bottom up approach, insert an entry in the node and
      # request the parent to modify itself if a node
      # splitting occurs
      # The split lets the new node at the right of the old
      # one.
      index = get_index(k)
      
      # First insert the key at the computed index
      @keys.insert(index, k)

      # The insertion of the child is performed differently
      # in a leaf than in a usual node because the child is a
      # mere list of value in the leaf and a reference to
      # another node in a usual node.
      insert_value(index, v)

      # If the node becomes too big, split in half and require
      # the parent to add the right node as a new node
      split_node if @keys.length > @max_branching
    end

    def i_am_your_father!
      # Tell the node to signal to its children it is their
      # father. Necessary when some children are relocated
      @children.each{|child| child.set_parent(self)}
    end
      
  protected

    def set_parent(node)
      # When a Node is split, the split off node needs to be
      # linked to its parent
      @parent = node
    end

  private

    def split_node
      # The node is split in two
      mid = @keys.length / 2

      # The range is different if the node is a leaf
      # i.e. If the node is a leaf the mid value still
      # appears in the child
      r, s = extra_node_range

      extra_key = @keys[mid]
      extra_node  = cut_off_node(r, s)

      # Tell the children of the new node their true father
      extra_node.i_am_your_father!() unless leaf?
      # The leaf doesn't contain children nodes
      
      # Update the old node
      @keys = @keys[0...mid]
      @children = @children[0..mid]

      # There is no parent to call if the current node is
      # root
      if root?
        build_new_root(extra_key, extra_node) 
      else
        # Ask the parent to register the new node
        @parent.add_entry(extra_key, extra_node)
      end
    end

    def build_new_root(extra_key, extra_node)
      # usefull when splitting the root
      keys = [extra_key]
      children = [self, extra_node]
      @parent = BPlusNode.new(@branching_factor, keys, children)
      @parent.i_am_your_father!
    end

    def cut_off_node(r, s)
      # Create a new node with the keys in range r and the
      # children in range s.
      # The ranges change if the node is a leaf, so this
      # method is overriden in the leaf class
      BPlusNode.new(@branching_factor, @keys[r], @children[s])
    end

    def extra_node_range
      # Computes the number of children and keys to cut off 
      # the node and put in another node when splitting.
      # These ranges change in the leaves, this method is
      # overriden there
      r = ((@max_branching + 3) / 2)..@max_branching
      s = ((@max_branching + 3) / 2)..(@max_branching + 1)
      return [r, s] 
    end

    def insert_value(index, v)
      # insert a child. In a usual node the child is
      # referenced by the key at the previous index, it is
      # not the same in leaves where the stored values are at
      # the same index than their keys.
      @children.insert(index + 1, v)
      # When a node gets a new child, this child needs to
      # know its parent
      i_am_your_father!
    end

    def get_index(key,_beg = 0, _end = @keys.length - 1)
      # If the Node is empty, the first index to be assigned
      # is 0.
      return 0 if @keys.empty? 

      # Else, perform dichotomic search to find the child
      # node which contains the given key
      beg_value = @keys[_beg]
      end_value = @keys[_end]

      result = case beg_value <=> key
        when -1 then
          # The key is higher than the lower bound
          case end_value <=> key
            when 1 then
              # The key is smaller than the upper bound
              _mid = (_beg + _end) / 2
              return _beg if _mid == _beg
              mid_value = @keys[_mid]
              case mid_value <=> key
                # Recursive dichotomic search
                when -1 then get_index(key, _mid, _end)
                when  1 then get_index(key, _beg, _mid)
                when  0 then _mid
              end
            else
              return _end + 1
          end
        when 0 then
          return _beg + 1
        else
          return _beg
      end
    end
  end

  class BPlusLeaf < BPlusNode
    attr_reader :next_leaf, :prev_leaf
    def initialize(b, keys = [], children = [], parent = nil, next_leaf = nil, prev_leaf = nil)
      @branching_factor = b
      @keys = keys
      @children = children
      @parent = parent
      @max_branching = b - 1
      @next_leaf = next_leaf
      @prev_leaf = prev_leaf

    end

    def leaf? # Override
      # A leaf inherits from the node object.
      true
    end

    def bulk_add(entries)
      # Builds the tree bottom up from a list of leaves
      mem = nil
      mem_index = @keys.length - 1
      entries.each_with_index do |e, i|
        k, v = e
        if @keys.length == @max_branching
          next_node = BPlusLeaf.new(@branching_factor, [], [], nil, nil, self)
          @next_node = next_node
          if root?
            build_new_root(k, next_node) 
          else
            # Ask the parent to register the new node
            @parent.add_entry(k, next_node)
          end
          next_node.bulk_add(entries[i..-1])
          return
        end
        (no_change = (k == mem)) if mem
        unless no_change
          @keys << k
          @children << [v]
          mem = k
          mem_index += 1
        else
          @children[mem_index] << v
          no_change = false
        end
      end 
    end

    def to_s # Override
      # Compared to the string representation of a usual
      # node, the leaf needs to print its stored values too
      # "[key: (value, value...) | key: .... ]"
      unless @keys.empty?
        items = (0..(@keys.length - 1)).collect do |index|
        "#{@keys[index]}: (#{@children[index].join(', ')})"
        end
        str = "[ #{items.join(' | ')} ]"
      else
        str = "[  ]"
      end
    end

    def insert(k, v) # Override
      # Inserting an entry in a leaf checks if the key exists
      if @keys.include?(k)
        # If it exists, the value is appended to its
        # corresponding bucket
        index = @keys.index(k)
        @children[index] << v
      else
        # Else the entry needs to be fully added
        add_entry(k, v) # defined in the node class
      end
    end

    def extra_node_range # Override
      # For a leaf the mid value is kept (all the values stay
      # in the leaf) and the range kept for the keys and the
      # children are the same. 
      r = ((@max_branching + 1) / 2)..@max_branching
      return [r, r]
    end

    def insert_value(index, v) # Override
      # appends v to its bucket, defining the bucket if
      # necessary
      @children[index] ||= []
      @children[index] << v
    end

    def cut_off_node(r, s) # Override
      # For a leaf, the next and previous leaves need to be
      # given when a new leaf appears.
      BPlusLeaf.new(@branching_factor, @keys[r], @children[s],
      @parent, @next, self)
    end
  end

  def initialize(b)
    # A void root
    @root = BPlusLeaf.new(b, [], [], nil)
    @branching_factor = b
  end

  def self.bulk_load(entries, b)
    # constructs the tree bottom up from a list of entries
    obj = self.new(b)
    entries.sort_by!{|e| [e[0], e[1]]}
    obj.root.bulk_add(entries)
    obj.update_root
    obj
  end

  def update_root
    while @root.parent
      @root = @root.parent
    end
  end


  def add_entry(key, value)
    # The insert request is given to the root, trickles down
    # the tree, is processed by a leaf, and then triggers a
    # bottom up balancing of the tree
    @root.insert(key, value)
    # Inserting a value may trigger a fork at the top of the
    # tree, resulting in a new root
    @root = @root.parent if @root.parent
  end

  def remove_entry
  end

  def to_s
    # Prints and centers line by line each layer of nodes
    layers = []
    # Stores the list of nodes at the current depth of the
    # tree
    nodes = [@root]
    # Keep track of the longest line to center the current
    # line
    _max = 0
    loop do
      # Print the layer of nodes at the current depth in the
      # tree
      new_layer = print_layer(nodes)
      # Center the string corresponding to the layer by
      # padding with spaces
      unless layers.length == 0
        l = new_layer.length
        if l < _max
          new_layer = ' '*((_max - l)/2) + new_layer
        elsif l > _max
          layers.collect! do |layer|
            ' '*((l - _max) / 2) + layer
          end
          _max = l
        end
      end
      layers << new_layer
      
      # gets the layers at the next depth in the graph
      nodes.collect!{ |node| node.children }.flatten!
      break unless nodes[0].is_a?(BPlusNode) 
    end
    # prints each layer in the graph as a line
    layers.join("\n")
  end

  def print_layer(nodes)
    # to get the string for a layer, i concatenate the
    # strings for each node in the layer.
    nodes.collect{ |node| node.to_s }.join(' ')
  end
end
