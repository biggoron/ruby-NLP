class BPlusTree
  attr_reader :root

  class BPlusNode
    attr_reader :keys, :children, :parent, :branching_factor
    def initialize(b, keys = [], children = [], parent = nil)
      @branching_factor = b
      @keys = keys
      @children = children
      @parent = parent
      @max_branching = b - 1

      # One can insert values only from the top of the tree
      if root?
        self.class_eval{public :insert}
      else
        self.class_eval{private :insert}
      end
    end

    def leaf?
      return self.is_a?(BPlusLeaf) ? true : false
    end

    def root?
      # A node is root <=> a node has no parent
      return (not parent)
    end

    protected
    def insert(k, v)
      # Top down approach, the insert request trickles down
      # Get the index of the children which range includes k
      index = get_index(k)
      # Make the child insert the entry
      @children[index].insert(k, value)
    end
    
    def add_entry(k, v)
      # Top up approach, insert an entry in the node and
      # request the parent to modify itself if a node
      # splitting occurs
      # The split lets the new node at the right of the old
      # one.
      index = get_index(k)
      @keys.insert(k, index)

      # TODO: Put in a separate method
      if self.is_a?(BPlusLeaf)
        @children[k] << v
      else
        @children.insert(v, index + 1)
      end

      # If the k becomes the first key, update the parent
      @parent.change_key(0, k) if index == 0

      # If the node becomes to big, split in half and require
      # the parent to add the right node as a new node
      if @keys.length > @max_branching
        mid = @keys.length / 2

        # TODO: Put in a separate method
        if self.is_a?(BPlusLeaf)
          r = mid..(@keys.length - 1)
        else
          r = (mid + 1)..(@keys.length - 1)
        end

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
    end

    def set_parent(node)
      @parent = node
    end

    private

    def i_am_your_father!
      @children.each{|child| child.set_parent(self)}
    end

    def build_new_root(extra_key, extra_node)
      keys = [extra_key]
      children = [self, extra_node]
      @parent = BPlusNode.new(@branching_factor, keys, children)
    end
      
    def get_index(key,_beg = 0, end = @keys.length - 1)
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

    def add_entry(k, v)
      # TODO: meme chose en rajoutant next, prev
    end
  end

  def initialize(b)
    @root = BPlusLeaf.new(b, [], [], nil)
  end

  def self.bulk_load(entries, b)
    # TODO: bottom up only
  end

  def add_entry(key, value)
    @root.insert(key, value)
    @root = @root.parent if @root.parent
  end

  def remove_entry
  end
end
