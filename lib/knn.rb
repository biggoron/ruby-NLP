# encoding: utf-8

# K-nearest-neighbours implementation
# Dan Ringwald @ Recast.AI @ Paris
# contact: dan.ringwald12@gmail.com

require './lib/b_plus_tree'

class Knn
  attr_accessor :ref_points
  attr_reader :branching_factor

  def initialize(values = nil, params = {})
    # The reference points for iDistance should be given
    @ref_points = params[:ref_points]
    # Else the barycenter is used as the only reference
    @ref_points ||= [mean(values)]
    # Gives the precision used for the float keys
    @tree_precision = params[:precision]
    @tree_precision ||= 0.0000001
    # Computes keys
    entries = values.collect{ |v| [key(v), v] }
    @branching_factor = params[:branching_factor]
    @branching_factor ||= 15 # TODO: find a default number
    # Create tree
    @tree = BPlusTree.bulk_load(entries, @branching_factor)
    # It is usefull to keep track of the number of entries to
    # be sure we don't ask for more neighbours than possible
    @stored_entries = values.length if values
  end

  def add_seeds(values)
    # Adds values in the tree, one by one
    values.each do |v|
      @tree.add_entry(key(v), v)
      @stored_entries ||= 0
      @stored_entries += 1
    end
  end

  def get_k(value, k)
    # Get the k nearest neighbours to the entry

    raise ArgumentError, 'There is not enough registered points to satisfy the request' if k >= @stored_entries

    d = 0.001
    mem = nil
    low = nil
    high = nil

    loop do
      # Dichotomic search of the good radius of search to get
      # k neighbours
      estimate = get_d(value, d)
      power = Math.log10(@tree_precision).floor
      trigger = 10**power
      # If the distance doesn't move more in one step than
      # the precision on the keys of the tree, then the
      # dichotomic search has finished searching
      return estimate if mem && (d - mem) < trigger
      case estimate.length <=> k
      when 1
        high = d
        d = low ? (d + low) / 2.0 : d * 0.75
      when -1
        low = d
        d = high ? (d + high) / 2.0 : d * 2
      when 0
        return estimate
      end
    end
  end

  def get_d(value, distance)
    # Get all points within distance d from entry
    candidates = []
    @ref_points.each_with_index do |ref, i|
      ref_dist = dist(ref, value)
      begin_ = i + normalize(ref_dist - distance)
      end_ = i + normalize(ref_dist + distance)
      # issues a range request on the B+ tree
      result = @tree.get(begin_, end_)
      candidates.concat(result)
    end
    candidates.select! do |c|
      # The answer is within the values returned by the tree
      lazy_compare(value, c, distance)
    end
    # Return an empty list if nothing were found
    candidates ? candidates : []
  end

  def key(v)
    # Computes the key of the value v
    index, distance = get_closer_ref(v)
    index + normalize(distance)
  end

  def get_closer_ref(v)
    # Gets the closer reference and the distance to it
    index, distance = @ref_points.each_with_object([0, :infinity, -1]) do |p, mem|
      mem[2] += 1
      d = dist(p, v)
      next unless mem[1] == :infinity || d < mem[1]
      mem[1] = d
      mem[0] = mem[2]
    end
    [index, distance]
  end

  def mean(values)
    # Computes the mean of a sequence of vectors
    total = values.length
    first = Array.new(values[0].length, 0)
    sum = values.each_with_object(first) do |v, temp_sum|
      v.each_with_index{ |e, i| temp_sum[i] += e }
    end
    sum.collect!{ |e| e.to_f / total }
  end

  def normalize(distance)
    # Takes a distance (possibly negative) and maps it to [0, 1]
    # segment.
    # Such a normalization is precise enough to guaranty that
    # two distance will have two different keys, if they
    # differ by dx/x > x * 10^(-7) asymptotically
    return 0 if distance <= 0
    digits = - Math.log10(@tree_precision).ceil
    (Math.atan(distance) * 2 / Math::PI).round(digits)
  end

  def dist(v1, v2)
    # computes a simple distance
    d, = v1.each_with_object([0, 0]) do |v, mem|
      mem[0] += (v - v2[mem[1]]) * (v - v2[mem[1]])
      mem[1] += 1
    end
    Math.sqrt(d)
  end

  def lazy_compare(v1, v2, distance)
    # returns false as soon as possible if the distance
    # between v1 and v2 is going to exceed distance

    d2 = distance * distance

    v1.each_with_object([0, 0]) do |v, mem|
      mem[0] += (v - v2[mem[1]]) * (v - v2[mem[1]])
      return false if mem[0] > d2
      mem[1] += 1
    end
    true
  end
end
