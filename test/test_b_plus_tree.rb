require 'minitest/autorun'
require "./lib/b_plus_tree"

class TestBPlusTree < Minitest::Test
  def setup
    @original_tree = BPlusTree.new(4)
    @entries = [[5, 320], [6, 321]]
  end

  # Test Constructeur

  def test_original_tree
    assert_equal @original_tree.is_a?(BPlusTree), true
    assert_equal @original_tree.to_s, '[  ]'
    assert_equal @original_tree.root.is_a?(BPlusTree::BPlusLeaf), true
  end

  # Test insert

  def test_insert_in_original_tree
    new_str = "[ 5: (320) ]"
    @original_tree.add_entry(5, 320)
    assert_equal @original_tree.to_s, new_str
  end

  def test_insert_in_same_bucket
    new_str = "[ 5: (320, 321) ]"
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(5, 321)
    assert_equal @original_tree.to_s, new_str
  end

  def test_insert_in_another_bucket
    new_str = "[ 5: (320) | 6: (321) ]"
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(6, 321)
    assert_equal @original_tree.to_s, new_str
  end

  def test_split_leaf
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(6, 321)
    @original_tree.add_entry(8, 440)
    @original_tree.add_entry(10, 4240)
    line1, line2 = @original_tree.to_s.split("\n")
    assert_equal line1.sub(/^ */, ''), "[ 8 ]"
    assert_equal line2.sub(/^ */, ''), "[ 5: (320) | 6: (321) ] [ 8: (440) | 10: (4240) ]"
  end

  def test_split_leaf_adds_an_entry_in_parent
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(6, 321)
    @original_tree.add_entry(8, 440)
    @original_tree.add_entry(10, 4240)
    @original_tree.add_entry(14, 8240)
    @original_tree.add_entry(15, 87)
    line1, line2 = @original_tree.to_s.split("\n")
    assert_equal line1.sub(/^ */, ''), "[ 8 | 14 ]"
    assert_equal line2.sub(/^ */, ''), "[ 5: (320) | 6: (321) ] [ 8: (440) | 10: (4240) ] [ 14: (8240) | 15: (87) ]"
  end

  def test_split_parent
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(6, 321)
    @original_tree.add_entry(8, 440)
    @original_tree.add_entry(10, 4240)
    @original_tree.add_entry(14, 8240)
    @original_tree.add_entry(15, 87)
    @original_tree.add_entry(16, 88)
    @original_tree.add_entry(17, 98)
    @original_tree.add_entry(18, 819)
    @original_tree.add_entry(20, 992)
    @original_tree.add_entry(25, 4678)
    @original_tree.add_entry(30, 9678)
    line1, line2, line3 = @original_tree.to_s.split("\n")
    leaves = "[ 5: (320) | 6: (321) ] [ 8: (440) | 10: (4240) ] [ 14: (8240) | 15: (87) ] "
    leaves << "[ 16: (88) | 17: (98) ] [ 18: (819) | 20: (992) ] [ 25: (4678) | 30: (9678) ]"
    assert_equal line1.sub(/^ */, ''), "[ 16 ]"
    assert_equal line2.sub(/^ */, ''), "[ 8 | 14 ] [ 18 | 25 ]"
    assert_equal line3.sub(/^ */, ''), leaves
  end

  # Test bulk load

  def test_bottom_up_build_can_build_a_simple_tree
    new_str = "[ 5: (320) | 6: (321) ]"
    my_tree = BPlusTree.bulk_load(@entries, 4)
    assert_equal my_tree.to_s, new_str
  end

  def test_bottom_up_build_can_add_in_same_bucket
    @entries << [5, 230]
    new_str = "[ 5: (230, 320) | 6: (321) ]"
    my_tree = BPlusTree.bulk_load(@entries, 4)
    assert_equal my_tree.to_s, new_str
  end

  def test_bottom_up_build_can_fork_leaves
    @entries << [8, 440]
    @entries << [10, 4240]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    line1, line2 = my_tree.to_s.split("\n")
    assert_equal line1.sub(/^ */, ''), "[ 10 ]"
    assert_equal line2.sub(/^ */, ''), "[ 5: (320) | 6: (321) | 8: (440) ] [ 10: (4240) ]"
  end

  def test_bottom_up_build_can_fill_up_parent_nodes
    @entries << [8, 440]
    @entries << [10, 4240]
    @entries << [14, 8240]
    @entries << [15, 87]
    @entries << [16, 88]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    line1, line2 = my_tree.to_s.split("\n")
    assert_equal line1.sub(/^ */, ''), "[ 10 | 16 ]"
    assert_equal line2.sub(/^ */, ''), "[ 5: (320) | 6: (321) | 8: (440) ] [ 10: (4240) | 14: (8240) | 15: (87) ] [ 16: (88) ]"
  end
  
  def test_bottom_up_build_can_split_usual_nodes
    @entries << [7, 340]
    @entries << [8, 440]
    @entries << [9, 460]
    @entries << [10, 4240]
    @entries << [11, 4340]
    @entries << [12, 5340]
    @entries << [13, 5341]
    @entries << [14, 8240]
    @entries << [15, 78]
    @entries << [16, 88]
    @entries << [17, 98]
    @entries << [18, 819]
    @entries << [19, 829]
    @entries << [20, 992]
    @entries << [25, 4678]
    @entries << [30, 9678]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    line1, line2, line3 = my_tree.to_s.split("\n")
    leaves = "[ 5: (320) | 6: (321) | 7: (340) ] [ 8: (440) | 9: (460) | 10: (4240) ] "
    leaves << "[ 11: (4340) | 12: (5340) | 13: (5341) ] [ 14: (8240) | 15: (78) | 16: (88) ] "
    leaves << "[ 17: (98) | 18: (819) | 19: (829) ] [ 20: (992) | 25: (4678) | 30: (9678) ]"
    assert_equal line1.sub(/^ */, ''), "[ 14 ]"
    assert_equal line2.sub(/^ */, ''), "[ 8 | 11 ] [ 17 | 20 ]"
    assert_equal line3.sub(/^ */, ''), leaves
  end

  # Test deletion

  def test_removing_a_value_in_a_bucket_works
    new_str = "[ 5: (320) ]"
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(5, 321)
    @original_tree.remove_entry(5, 321)
    assert_equal @original_tree.to_s, new_str
  end
    
  def test_removing_a_bucket_works
    new_str = "[ 5: (320) ]"
    @original_tree.add_entry(5, 320)
    @original_tree.add_entry(6, 321)
    @original_tree.remove_entry(6, 321)
    assert_equal @original_tree.to_s, new_str
  end

  def test_borrowing_values_to_neighbours_works_in_leaves
    @entries << [7, 340]
    @entries << [8, 440]
    @entries << [9, 460]
    @entries << [10, 4240]
    @entries << [11, 4340]
    @entries << [12, 5340]
    @entries << [13, 5341]
    @entries << [14, 8240]
    @entries << [15, 78]
    @entries << [16, 88]
    @entries << [17, 98]
    @entries << [18, 819]
    @entries << [19, 829]
    @entries << [20, 992]
    @entries << [25, 4678]
    @entries << [30, 9678]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    my_tree.remove_entry(6, 321)
    my_tree.remove_entry(7, 340)
    my_tree.remove_entry(20, 992)
    my_tree.remove_entry(25, 4678)
    line1, line2, line3 = my_tree.to_s.split("\n")
    leaves = "[ 5: (320) | 8: (440) ] [ 9: (460) | 10: (4240) ] "
    leaves << "[ 11: (4340) | 12: (5340) | 13: (5341) ] [ 14: (8240) | 15: (78) | 16: (88) ] "
    leaves << "[ 17: (98) | 18: (819) ] [ 19: (829) | 30: (9678) ]"
    assert_equal line1.sub(/^ */, ''), "[ 14 ]"
    assert_equal line2.sub(/^ */, ''), "[ 9 | 11 ] [ 17 | 19 ]"
    assert_equal line3.sub(/^ */, ''), leaves
  end

  def test_merging_works
    # It also tests root deletion when merging at depth 1
    @entries << [7, 340]
    @entries << [8, 440]
    @entries << [9, 460]
    @entries << [10, 4240]
    @entries << [11, 4340]
    @entries << [12, 5340]
    @entries << [13, 5341]
    @entries << [14, 8240]
    @entries << [15, 78]
    @entries << [16, 88]
    @entries << [17, 98]
    @entries << [18, 819]
    @entries << [19, 829]
    @entries << [20, 992]
    @entries << [25, 4678]
    @entries << [30, 9678]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    my_tree.remove_entry(6, 321)
    my_tree.remove_entry(7, 340)
    my_tree.remove_entry(8, 440)
    my_tree.remove_entry(20, 992)
    my_tree.remove_entry(25, 4678)
    line1, line2 = my_tree.to_s.split("\n")
    leaves = "[ 5: (320) | 9: (460) | 10: (4240) ] "
    leaves << "[ 11: (4340) | 12: (5340) | 13: (5341) ] [ 14: (8240) | 15: (78) | 16: (88) ] "
    leaves << "[ 17: (98) | 18: (819) ] [ 19: (829) | 30: (9678) ]"
    assert_equal line1.sub(/^ */, ''), "[ 11 | 14 | 17 | 19 ]"
    assert_equal line2.sub(/^ */, ''), leaves
  end
  
  def test_integration_integer
    @entries << [7, 340]
    @entries << [8, 440]
    @entries << [9, 460]
    @entries << [10, 4240]
    @entries << [11, 4340]
    @entries << [12, 5340]
    @entries << [13, 5341]
    @entries << [14, 8240]
    @entries << [15, 78]
    @entries << [16, 88]
    @entries << [17, 98]
    @entries << [18, 819]
    @entries << [19, 829]
    @entries << [20, 992]
    @entries << [25, 4678]
    @entries << [30, 9678]
    my_tree = BPlusTree.bulk_load(@entries, 4)
    my_tree.remove_entry(6, 321)
    my_tree.remove_entry(7, 340)
    my_tree.remove_entry(8, 440)
    my_tree.remove_entry(20, 992)
    my_tree.remove_entry(25, 4678)
    my_tree.add_entry(7, 322)
    my_tree.add_entry(7, 232)
    my_tree.add_entry(18, 729)
    my_tree.add_entry(18, 738)
    get5 = my_tree.get(5)
    get7 = my_tree.get(7)
    get18 = my_tree.get(18)
    get_r58 = my_tree.get(5, 8)
    get_r28 = my_tree.get(-2, 8)
    get_r1523 = my_tree.get(15, 23)
    get_r1550 = my_tree.get(15, 50)
#   assert_equal my_tree.inspect, my_tree.to_s
    assert_equal get5, [320]
    assert_equal get7, [232, 322]
    assert_equal get18, [729, 738, 819]
    assert_equal get_r58, [232, 320, 322]
    assert_equal get_r28, [232, 320, 322]
    assert_equal get_r1523, [78, 88, 98, 729, 738, 819, 829]
    assert_equal get_r1550, [78, 88, 98, 729, 738, 819, 829, 9678]
  end

  def test_integration_float
    entries = Array(1..15)
    entries.collect!{ |v| [Math::tan(v).round(5), v] }
    my_tree = BPlusTree.bulk_load(entries, 4)
    my_tree.remove_entry(Math::tan(6).round(5), 6)
    my_tree.add_entry(Math::tan(8.5).round(5), 8.5)
    get7 = my_tree.get(Math::tan(7).round(5))
    assert_equal get7, [7]
  end
end
