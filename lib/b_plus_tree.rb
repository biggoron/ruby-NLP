# encoding: utf-8

class BPlusTree
  attr_reader :root

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

      # One can insert values only from the top of the tree
      # Don't worry, the tree keeps track only of the root
      # anyway
      if root?
        self.class_eval{ public :insert }
      else
        self.class_eval{ private :insert }
      end
    end

    def leaf?
      # A leaf inherits from the node object.
      self.is_a?(BPlusLeaf) ? true : false
    end

    def root?
      # A node is root <=> a node has no parent
      !parent
    end

    protected

    # These method can also be used by leaves or other usual
    # nodes to forward insert or delete requests.

    def insert(k, v)
      # Top down approach, the insert request trickles down
      # the Tree
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
      @keys.insert(k, index)

      # The insertion of the child is performed differently
      # in a leaf than in a usual node
      insert_value(index, v)

      # If the node becomes too big, split in half and require
      # the parent to add the right node as a new node
      split_node if @keys.length > @max_branching
    end

    def set_parent(node)
      @parent = node
    end

    private

    def split_node
      # The node is split in two
      mid = @keys.length / 2

      # The range is different if the node is a leaf
      # i.e. If the node is a leaf the mid value still
      # appears in the child
      r = extra_node_range

      extra_key = @keys[mid]
      extra_node = BPlusNode.new(@branching_factor, @keys[r], @children[r])

      # Tell the children of the new node their true father
      extra_node.i_am_your_father!()
      
      # Update the old node
      @keys = @keys[0...mid]
      @children = @children[0...mid]

      # There is no parent to call if the current node is
      # root
      if root?
        build_new_root(extra_key, extra_node) 
      else
        # Ask the parent to register the new node
        @parent.add_entry(extra_key, extra_node)
      end
      # Return
      nil
    end

    def extra_node_range
      return ((@max_branching + 3) / 2)..@max_branching
    end

    def insert_value(index, v)
      @children.insert(v, index + 1)
    end

    def i_am_your_father!
      @children.each{|child| child.set_parent(self)}
    end

    def build_new_root(extra_key, extra_node)
      keys = [extra_key]
      children = [self, extra_node]
      @parent = BPlusNode.new(@branching_factor, keys, children)
    end
      
    def get_index(key,_beg = 0, _end = @keys.length - 1)
      # If the Node if empty, the first index to be assigned
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

    def bulk_add(entries)
      mem = nil
      mem_index = 0
      entries.each_with_index do |k, v, i|
        if @keys.length == @branching_factor
          next_node = BPlusLeaf.new(b, [], [], nil, nil, self)
          @next_node = next_node
          if root?
            build_new_root(k, next_node) 
          else
            # Ask the parent to register the new node
            @parent.add_entry(k, next_node)
          end
          next_node.bulk_load(entries[i..-1])
        end
        (no_change = (k == mem)) if mem
        unless no_change
          @keys << k
          @children << [v]
          mem == k
          mem_index += 1
        else
          @children[mem_index] << v
        end
      end 
    end

    protected

    def insert(k, v)
      if @keys.include?(k)
        index = @keys.index(k)
        @children[index] << v
        return nil
      else
        add_entry(k, v)
      end
    end

    private
    def extra_node_range
      return ((@max_branching + 1) / 2)..@max_branching
    end

    def insert_value(index, v)
      @children[index] << v
    end
  end

  def initialize(b)
    @root = BPlusLeaf.new(b, [], [], nil)
  end

  def self.bulk_load(entries, b)
    obj = self.new(b)
    entries.sort!{|k,v| k} 
    @root.bulk_add(entries)
  end

  def add_entry(key, value)
    @root.insert(key, value)
    # Inserting a value may trigger a fork at the top of the
    # tree, resulting in a new root
    @root = @root.parent if @root.parent
  end

  def remove_entry
  end
end
