#vim :e lib/term_frequency.rb
#vim :!rake test > log/bash_output.txt
#vim :vsp log/bash_output.txt

require 'minitest/autorun'
require './lib/term_frequency'

class TestTFHash < Minitest::Test
  def setup
    @data1        = []
    @data2        = ['simple']
    @data3        = ['simple', 'double']
    @data4        = ['simple', 'double', 'simple']
    @data5        = ['']
    @data6        = [333, 'double']
    @string_data1 = ""
    @string_data2 = "simple"
    @string_data3 = "simple double"
    @string_data4 = "simple, double"
    @string_data5 = "simple, double. simple"
    @file_data1   = "./data/no_text"
    @file_data2   = "./data/simple_text"
  end
  def test_TF_constructors_returns_tf_object
    assert_equal TFHash.new().class.name,                   'TFHash'
    assert_equal TFHash.from_array(@data1).class.name,      'TFHash'
    assert_equal TFHash.from_string('test').class.name,     'TFHash'
    assert_equal TFHash.from_file(@file_data1).class.name,  'TFHash'
  end
  def test_TF_constructors_returns_proper_hash
    assert_equal  TFHash.new().length,                       0
    assert_equal  TFHash.from_array(@data4).length,          2
    assert_equal  TFHash.from_array(@data4).max,             2
    assert_equal  TFHash.from_string(@string_data5).length,  2
    assert_equal  TFHash.from_string(@string_data5).max,     2
    assert_equal  TFHash.from_file(@file_data2).length,      18
    assert_equal  TFHash.from_file(@file_data2).max,         2
#   add the form file constructor
  end
  def test_add_array_fills_tfh
    my_TFH = TFHash.new()
    assert_equal my_TFH.add_array(@data2).length,  1
    assert_equal my_TFH.max,                       1
    assert_equal my_TFH.add_array(@data2).length,  1
    assert_equal my_TFH.max,                       2
    assert_equal my_TFH.add_array(@data3).length,  2
    assert_equal my_TFH.max,                       3
    assert_equal my_TFH.add_array(@data1).length,  2
    assert_equal my_TFH.max,                       3
    assert_equal my_TFH.add_array(@data5).length,  2
    assert_equal my_TFH.max,                       3
  end
  def test_add_file_fills_tfh
    my_TFH = TFHash.new([" ", ".", ",", "\n"])
    assert_equal my_TFH.add_file(@file_data2).length,  18
    assert_equal my_TFH.max,                           2
  end
  def test_add_string_fills_tfh
    my_TFH = TFHash.new([" ", ".", ",", "\n"])
    assert_equal my_TFH.add_string(@string_data1).length,  0
    assert_equal my_TFH.max,                               0
    assert_equal my_TFH.add_string(@string_data2).length,  1
    assert_equal my_TFH.max,                               1
    assert_equal my_TFH.add_string(@string_data3).length,  2
    assert_equal my_TFH.max,                               2
    assert_equal my_TFH.add_string(@string_data4).length,  2
    assert_equal my_TFH.max,                               3
  end
  def test_hash_bracket_access
    assert_equal TFHash.from_file(@file_data2)["the"],  2
  end
  def test_invalid_argument_raises_argument_exception
    assert_raises  ArgumentError do
      TFHash.from_array("string")
    end
    assert_raises  ArgumentError do
      TFHash.from_string(["some", "array"])
    end
    assert_raises  ArgumentError do
      TFHash.from_file(["some", "array"])
    end
  end
  def test_wrong_filenames_are_caught
    assert_raises Errno::ENOENT do
      TFHash.from_file("filename")
    end
  end
  def test_no_argument_raises_argument_exception
  # It is normally handled by default
    assert_raises ArgumentError do
      TFHash.from_array()
    end
  end
end
