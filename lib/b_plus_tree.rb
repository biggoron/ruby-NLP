class BPlusTree
  class BPlusNode
    attr_reader :values, :indexes, :root
    def initialize(values = [], indexes = [], root = nil)
      @values  = values  
      @indexes = indexes 
      @root = (root = :root)? true : false
    end
    def leaf?
      return false
    end
    def root?
      return @root
    end
    def add_bucket(key, b)
      extra_node = @indexes[get_index(key)].add_bucket(key, b)
      if extra_node
        new_extra_node = insert(extra_node) 
        return new_extra_node
      else
        return nil
      end
    end

  private
    def insert(node)
      value = node.values[0]
      index = get_index(value) 
      @values.insert(value, index)
      @indexes.insert(node, index + 1)
      if @values.length >= b
        _m = (b+1)/2
        extra_node = BPlusNode.new(@values[_m..-1], @indexes[_m..-1])
        @values = @values[0..._m]
        @indexes = @indexes[0..._m]
        if @root
          @root = false
          new_root = BPlusNode.new([extra_node.values[0]], [self, extra_node], :root)
          return new_root
        else
          return extra_node
        end
      else
        return nil
      end
    end
    def get_index(key, _beg = 0, _end = @values.length - 1)
    # Dichotomic search for the child node containing the given key
      b_value = @values[_beg] # lower bound of the search
      e_value = @values[_end] # upper bound of the search
      
      result = case b_value <=> key
        when -1 then # the key is higher than the lower bound
          case e_value <=> key
            when 1 then # the key is smaller than the upper bound
              _mid = (_beg + _end)/2
              return _beg if _mid = _beg
              m_value = @values[_mid]
              case m_value <=> key # dichotomic search
                when -1 then get_index(key, _mid, _end)
                when 1  then get_index(key, _beg, _mid)
                when 0  then _mid
              end
            else # the key is higher than the upper bound
              _end + 1
          end
        else # the key is smaller than the lower bound
          _beg
      end
      return result
    end
  end

  class BPlusLeaf < BPlusNode
    attr_reader :next, :prev
    def initialize(values = [], indexes = [], root, prev = nil, nxt = nil)
      super
      @next     = nxt
      @prev     = prev
      @previous = nil
      @root = (root == :root)? true : false
    end
    def leaf?
      return true
    end
    def add_bucket(key, b)
      return nil if @values.include?(key)
       
      index = get_index(key)
      @values.insert(key, index)
      @indexes.insert(nil, index)

      if @values.length >= b
        _m = (b+1)/2
        extra_node = BPlusLeaf.new(@values[_m..-1], @indexes[_m..-1], :not_root, self, self.next)
        @next = extra_node
        @values = @values[0..._m]
        @indexes = @indexes[0..._m]
        if @root
          @root = false
          new_root = BPlusNode.new([extra_node.values[0]], [self, extra_node], :root)
          return new_root
        else
          return extra_node
        end
      else
        return nil
      end
    end
  end

  attr_reader :root, :branching_factor

  def initialize(b)
    @root = BPlusLeaf.new([], [], :root)
    @branching_factor = b
  end

  def self.bulk_load(entries)
  end

  def add_bucket(key)
    @root.add_bucket(key, @branching_factor)
  end

  def add_entry(key, value)
  end

  def remove_bucket(key)
  end

  def remove_entry(key, value)
  end
end
